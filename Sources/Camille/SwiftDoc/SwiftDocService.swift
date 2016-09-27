import Bot
import Sugar

class SwiftDocService: SlackMessageService, SlackInteractiveButtonResponderService, SlackConnectionService {
    public let buttonResponder = SlackInteractiveButtonResponder()

    private var sync: SwiftDocSync?
    
    //MARK: - Connection
    func connected(slackBot: SlackBot, botUser: BotUser, team: Team, users: [User], channels: [Channel], groups: [Group], ims: [IM]) throws {
        self.sync = SwiftDocSync(
            http: slackBot.http,
            storage: slackBot.storage
        )
        try self.sync?.updateDataset()
    }
    
    //MARK: - Messages
    override func messageEvent(slackBot: SlackBot, webApi: WebAPI, message: MessageDecorator, previous: MessageDecorator?) throws {
        guard let sync = self.sync, let target = message.target else { return }
        
        try message.routeText(
            to: self.showDocs(in: target, webApi: webApi, sync: sync),
            matching: slackBot.me, String.any, "swift", String.any(name: "type")
        )
    }
}

//MARK: - Docs
fileprivate extension SwiftDocService {
    func showDocs(in target: SlackTargetType, webApi: WebAPI, sync: SwiftDocSync) -> (PatternMatchResult) throws -> Void {
        return { match in
            let type: String = match.value(named: "type")
            
            do {
                guard let data = try sync.lookup(item: type) as? InteractiveButtonChatPostMessageRepresentable
                    else { throw SwiftDocError.unableToDisplay(item: type) }
                
                let message = try data.makeInteractiveButtonChatPostMessage(
                    target: target,
                    responder: self,
                    handler: self.showDetails(with: webApi)
                )
                
                try webApi.execute(message)
                
            } catch let error {
                let reply = SlackMessage().add(segment: String(describing: error))
                try webApi.execute(reply.makeChatPostMessage(target: target))
            }
        }
    }
}

fileprivate extension SwiftDocService {
    func showDetails(with webApi: WebAPI) -> (InteractiveButtonResponse) throws -> Void {
        return { response in
            let message = try SlackMessage(
                    responseType: .ephemeral,
                    responseUrl: response.response_url
                )
                .line("hey")
                .makeChatPostMessage(target: response.channel)
            
            try webApi.execute(message)
        }
    }
}
