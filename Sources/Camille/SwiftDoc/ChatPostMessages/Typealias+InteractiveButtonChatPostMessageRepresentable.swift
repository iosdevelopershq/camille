import Bot
import Sugar
import Models

extension Typealias: InteractiveButtonChatPostMessageRepresentable {
    public func makeInteractiveButtonChatPostMessage(target: SlackTargetType, responder: SlackInteractiveButtonResponderService, handler: @escaping (InteractiveButtonResponse) throws -> Void) throws -> ChatPostMessage {
        
        let message = SlackMessage()
            .line("Details of: ", self.name.bold)
            .attachment { builder in
                builder.color(.orange)
                builder.text(self.comment, markdown: true)
                builder.field(short: true, title: "Kind", value: self.kind)
                builder.field(short: true, title: "Type", value: self.type)
            }
        
        return try message.makeChatPostMessage(target: target)
    }
}
