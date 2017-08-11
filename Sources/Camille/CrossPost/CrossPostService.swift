//import Bot
//import Sugar
//import Foundation
//
////MARK: - Service
//final class CrossPostService: SlackMessageService, SlackInteractiveButtonResponderService {
//    //MARK: - Properties
//    let buttonResponder = SlackInteractiveButtonResponder()
//    fileprivate let config: CrossPostServiceConfig
//    private var timer: TimerService?
//    private var messages: [MessageDecorator] = []
//    
//    //MARK: - Lifecycle
//    init(config: CrossPostServiceConfig) {
//        self.config = config
//    }
//    
//    //MARK: - Event Routing
//    func configureEvents(slackBot: SlackBot, webApi: WebAPI, dispatcher: SlackRTMEventDispatcher) {
//        self.configureMessageEvent(slackBot: slackBot, webApi: webApi, dispatcher: dispatcher)
//        self.timer = TimerService(id: "crossPosting", interval: self.config.timeSpan, storage: slackBot.storage, dispatcher: dispatcher) { [weak self] pong in
//            guard let `self` = self else { return }
//            
//            //get rid of messages older than config.timeSpan
//            let activeMessages = self.messages.filter(self.newerThan(timestamp: pong.timestamp, lifespan: self.config.timeSpan))
//            self.messages = activeMessages
//            
//            guard let message = self.makeCrossPostWarning(pong: pong, messages: self.messages, webApi: webApi) else { return }
//            
//            self.messages = []
//            
//            guard
//                let target = slackBot.target(nameOrId: self.config.reportingTarget)
//                else { return }
//            
//            try webApi.execute(message.makeChatPostMessage(target: target))
//        }
//    }
//    func messageEvent(slackBot: SlackBot, webApi: WebAPI, message: MessageDecorator, previous: MessageDecorator?) throws {
//        //only add new _channel_ messages and ones that meet the requirements
//        guard
//            message.target?.channel != nil,
//            previous == nil,
//            self.config.includeMessage(message)
//            else { return }
//        
//        self.messages.append(message)
//    }
//}
//
////MARK: - CrossPost Check
//fileprivate extension CrossPostService {
//    func makeCrossPostWarning(pong: Pong, messages: [MessageDecorator], webApi: WebAPI) -> SlackMessage? {
//        let duplicates = self.findCrossPosts(in: messages)
//        guard !duplicates.isEmpty else { return nil }
//        
//        let message = SlackMessage()
//            .line("Cross Post Alert:".bold)
//            .line("The following cross posts have been detected:")
//            .attachments(for: duplicates) { builder, dupes in
//                dupes.addAttachment(
//                    with: builder,
//                    buttonResponder: self,
//                    handler: self.buttonHandler(messages: dupes, webApi: webApi)
//                )
//            }
//        
//        return message
//    }
//}
//
////MARK: - CrossPost Data
//fileprivate extension CrossPostService {
//    func uniqueMessageKey(message: MessageDecorator) -> String {
//        let userId = message.sender?.id ?? ""
//        return "\(userId)\(message.text.hashValue)"
//    }
//    func potentialDuplicates(messages: [MessageDecorator]) -> Bool {
//        guard
//            messages.count > 1,
//            let first = messages.first,
//            first.sender != nil
//            else { return false }
//        
//        return !first.text.isEmpty
//    }
//    func postedInMultipleChannels(messages: [MessageDecorator]) -> Bool {
//        return messages
//            .grouped { $0.target?.name ?? "" }
//            .values.count > 1
//    }
//    func findCrossPosts(in messages: [MessageDecorator]) -> [[MessageDecorator]] {
//        let potentialDuplicates = messages
//            .grouped(by: self.uniqueMessageKey)
//            .values
//            .filter(self.potentialDuplicates)
//            .filter(self.postedInMultipleChannels)
//        
//        return Array(potentialDuplicates)
//    }
//}
//
////MARK: - Cross Post Button Responder
//fileprivate extension CrossPostService {
//    func buttonHandler(messages: [MessageDecorator], webApi: WebAPI) -> (InteractiveButtonResponse) throws -> Void {
//        return { response in
//            guard
//                let name = response.actions.first?.name,
//                let action = CrossPostButton(rawValue: name)
//                else { return }
//            
//            switch action {
//            case .publicWarning: try self.publicWarning(messages: messages, webApi: webApi)
//            case .privateWarning: try self.privateWarning(messages: messages, webApi: webApi)
//            case .removeAll: try self.removeAll(messages: messages, webApi: webApi)
//            }
// 
//            try self.updateWarning(
//                message: response.original_message,
//                after: action,
//                from: response,
//                webApi: webApi
//            )
//        }
//    }
//    
//    private func publicWarning(messages: [MessageDecorator], webApi: WebAPI) throws {
//        guard
//            let user = messages.first?.sender,
//            let target = messages.first?.target
//            else { return }
//        
//        let message = try self.config.publicWarning(target, user)
//        try webApi.execute(message)
//    }
//    private func privateWarning(messages: [MessageDecorator], webApi: WebAPI) throws {
//        guard let user = messages.first?.sender else { return }
//        
//        let openIm = IMOpen(user: user)
//        let im = try webApi.execute(openIm)
//        
//        let message = try self.config.privateWarning(im)
//        try webApi.execute(message)
//    }
//    private func removeAll(messages: [MessageDecorator], webApi: WebAPI) throws {
//        for message in messages {
//            let delete = ChatDelete(message: message.message)
//            try webApi.execute(delete)
//        }
//    }
//}
//
////MARK: - Helpers
//fileprivate extension CrossPostService {
//    func newerThan(timestamp: Int, lifespan: TimeInterval) -> (MessageDecorator) -> Bool {
//        return { message in
//            guard let messageTimestamp = Int(message.message.timestamp) else { return true }
//            return (timestamp - messageTimestamp) < Int(lifespan)
//        }
//    }
//}
//
//fileprivate extension CrossPostService {
//    func updateWarning(message: Message, after action: CrossPostButton, from interactiveButton: InteractiveButtonResponse, webApi: WebAPI) throws {
//        
//        let update = SlackMessage(message: message)
//            .updateAttachment(buttonResponse: interactiveButton) { builder in
//                builder.updateOrAddField(titled: "Actions Taken") { field in
//                    var values = field.value.components(separatedBy: "\n")
//                    values.append("<@\(interactiveButton.user.id)> chose: \(action.text)")
//                    field.value = values.joined(separator: "\n")
//                }
//                builder.removeButtons(matching: { !action.afterExecuted.map({ $0.rawValue }).contains($0.name) })
//            }
//        
//        try webApi.execute(try update.makeChatUpdate(to: message, in: interactiveButton.channel))
//    }
//}
//
