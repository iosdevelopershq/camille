import Bot
import Sugar
import Foundation

//MARK: - Config
struct CrossPostServiceConfig {
    let timeSpan: TimeInterval
    let reportingTarget: String
    let publicWarning: (SlackTargetType, User) throws -> ChatPostMessage
    let privateWarning: (IM) throws -> ChatPostMessage
}

//MARK: - Service
final class CrossPostService: SlackMessageService, SlackInteractiveButtonResponderService {
    //MARK: - Properties
    let buttonResponder = SlackInteractiveButtonResponder()
    fileprivate let config: CrossPostServiceConfig
    private var timer: TimerService?
    private var messages: [MessageDecorator] = []
    
    //MARK: - Lifecycle
    init(config: CrossPostServiceConfig) {
        self.config = config
    }
    
    //MARK: - Event Routing
    override func configureEvents(slackBot: SlackBot, webApi: WebAPI, dispatcher: SlackRTMEventDispatcher) {
        super.configureEvents(slackBot: slackBot, webApi: webApi, dispatcher: dispatcher)
        self.timer = TimerService(id: "crossPosting", interval: self.config.timeSpan, storage: slackBot.storage, dispatcher: dispatcher) { [weak self] pong in
            guard let `self` = self else { return }
            
            //get rid of messages older than config.timeSpan
            let activeMessages = self.messages.filter(self.newerThan(timestamp: pong.timestamp, lifespan: self.config.timeSpan))
            self.messages = activeMessages
            
            guard let message = self.makeCrossPostWarning(pong: pong, messages: self.messages, webApi: webApi) else { return }
            
            self.messages = []
            
            guard
                let target = slackBot.target(nameOrId: self.config.reportingTarget)
                else { return }
            
            try webApi.execute(message.makeChatPostMessage(target: target))
        }
    }
    override func messageEvent(slackBot: SlackBot, webApi: WebAPI, message: MessageDecorator, previous: MessageDecorator?) throws {
        self.messages.append(message)
    }
}

//MARK: - CrossPost Check
fileprivate extension CrossPostService {
    func makeCrossPostWarning(pong: Pong, messages: [MessageDecorator], webApi: WebAPI) -> SlackMessage? {
        let duplicates = self.findCrossPosts(in: messages)
        guard !duplicates.isEmpty else { return nil }
        
        let message = SlackMessage()
            .line("Cross Post Alert:".bold)
            .line("The following cross posts have been detected:")
            .attachments(for: duplicates) { builder, dupes in
                dupes.addAttachment(
                    with: builder,
                    buttonResponder: self,
                    handler: self.buttonHandler(messages: dupes, webApi: webApi)
                )
            }
        
        return message
    }
}

//MARK: - CrossPost Data
fileprivate extension CrossPostService {
    func uniqueMessageKey(message: MessageDecorator) -> String {
        let userId = message.sender?.id ?? ""
        return "\(userId)\(message.text.hashValue)"
    }
    func potentialDuplicates(messages: [MessageDecorator]) -> Bool {
        guard
            messages.count > 1,
            let first = messages.first,
            first.sender != nil
            else { return false }
        
        return !first.text.isEmpty
    }
    func findCrossPosts(in messages: [MessageDecorator]) -> [[MessageDecorator]] {
        let potentialDuplicates = messages
            .grouped(by: self.uniqueMessageKey)
            .values
            .filter(self.potentialDuplicates)
        
        return Array(potentialDuplicates)
    }
}

//MARK: - CrossPost Warning Message Generation
fileprivate enum ActionButton: String {
    case privateWarning
    case publicWarning
    case removeAll
    
    var text: String {
        switch self {
        case .privateWarning: return "Private Warning"
        case .publicWarning: return "Public Warning"
        case .removeAll: return "Remove all posts"
        }
    }
    
    static var all: [ActionButton] { return [.privateWarning, .publicWarning, .removeAll] }
}
fileprivate extension Sequence where Iterator.Element == MessageDecorator {
    func addAttachment(with builder: SlackMessageAttachmentBuilder, buttonResponder: SlackInteractiveButtonResponderService, handler: @escaping InteractiveButtonResponseHandler) {
        let array = Array(self)
        guard let user = array.first?.sender, let message = array.first else { return }
        let channels = self
            .flatMap { $0.target?.channel }
            .map { "<#\($0.id)>" }
            .joined(separator: ", ")
        
        builder.field(short: true, title: "User", value: "<@\(user.id)>")
        builder.field(short: true, title: "Channels", value: channels)
        builder.field(short: false, title: "Message Preview", value: message.text.substring(to: 50))
        for button in ActionButton.all {
            builder.button(
                name: button.rawValue,
                text: button.text,
                responder: buttonResponder,
                handler: handler
            )
        }
    }
}

//MARK: - Cross Post Button Responder
fileprivate extension CrossPostService {
    func buttonHandler(messages: [MessageDecorator], webApi: WebAPI) -> (InteractiveButtonResponse) throws -> Void {
        return { response in
            guard
                let name = response.actions.first?.name,
                let action = ActionButton(rawValue: name)
                else { return }
            
            switch action {
            case .publicWarning: try self.publicWarning(messages: messages, webApi: webApi)
            case .privateWarning: try self.privateWarning(messages: messages, webApi: webApi)
            case .removeAll: try self.removeAll(messages: messages, webApi: webApi)
            }
        }
    }
    
    private func publicWarning(messages: [MessageDecorator], webApi: WebAPI) throws {
        guard
            let user = messages.first?.sender,
            let target = messages.first?.target
            else { return }
        
        let message = try self.config.publicWarning(target, user)
        try webApi.execute(message)
    }
    private func privateWarning(messages: [MessageDecorator], webApi: WebAPI) throws {
        guard let user = messages.first?.sender else { return }
        
        let openIm = IMOpen(user: user)
        let im = try webApi.execute(openIm)
        
        let message = try self.config.privateWarning(im)
        try webApi.execute(message)
    }
    private func removeAll(messages: [MessageDecorator], webApi: WebAPI) throws {
        for message in messages {
            let delete = ChatDelete(message: message.message)
            try webApi.execute(delete)
        }
    }
}

//MARK: - Helpers
fileprivate extension CrossPostService {
    func newerThan(timestamp: Int, lifespan: TimeInterval) -> (MessageDecorator) -> Bool {
        return { message in
            guard let messageTimestamp = Int(message.message.timestamp) else { return true }
            return (timestamp - messageTimestamp) < Int(lifespan)
        }
    }
}
