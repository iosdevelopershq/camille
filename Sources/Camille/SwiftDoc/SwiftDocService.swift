import Bot
import Sugar

class SwiftDocService: SlackMessageService, SlackConnectionService {
    private var sync: SwiftDocSync?
    
    func connected(slackBot: SlackBot, botUser: BotUser, team: Team, users: [User], channels: [Channel], groups: [Group], ims: [IM]) throws {
        self.sync = SwiftDocSync(
            http: slackBot.http,
            storage: slackBot.storage
        )
        try self.sync?.updateDataset()
    }
    
    override func messageEvent(slackBot: SlackBot, webApi: WebAPI, message: MessageDecorator, previous: MessageDecorator?) throws {
        guard let sync = self.sync, let target = message.target else { return }
        
        try message.routeText(
            to: self.showDocs(in: target, webApi: webApi, sync: sync),
            matching: slackBot.me, String.any, "swift", String.any(name: "type")
        )
    }
}

fileprivate extension SwiftDocService {
    func showDocs(in target: SlackTargetType, webApi: WebAPI, sync: SwiftDocSync) -> (PatternMatchResult) throws -> Void {
        return { match in
            let type: String = match.value(named: "type")
            
            do {
                guard let data = try sync.lookup(item: type) as? ChatPostMessageRepresentable
                    else { throw SwiftDocError.unableToDisplay(item: type) }
                
                try webApi.execute(try data.makeChatPostMessage(target: target))
                
            } catch let error {
                let reply = SlackMessage(target: target).text(String(describing: error))
                try webApi.execute(reply.apiMethod())
            }
        }
    }
}
