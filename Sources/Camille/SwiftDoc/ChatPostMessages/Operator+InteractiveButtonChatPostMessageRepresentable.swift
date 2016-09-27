import Bot
import Sugar
import Models

extension Operator: InteractiveButtonChatPostMessageRepresentable {
    public func makeInteractiveButtonChatPostMessage(target: SlackTargetType, responder: SlackInteractiveButtonResponderService, handler: @escaping InteractiveButtonResponseHandler) throws -> ChatPostMessage {
        
        var message = SlackMessage()
            .line("Details of: ", self.name.bold)
            .attachment { builder in
                builder.color(.orange)
                
//                let buttonMap: [String: [Any]] = [
//                    "Functions": self.functions,
//                ]
//                
//                let buttons: [String] = buttonMap.flatMap { item -> String? in
//                    return (item.value.isEmpty ? nil : item.key)
//                }
                
                builder.field(short: false, title: "Type", value: self.kind)
                builder.field(short: true, title: "Associativity", value: self.associativity)
                builder.field(short: true, title: "Precedence", value: self.precedence)
                
//                for button in buttons {
//                    //builder.button(name: button, text: button, responder: responder, handler: handler)
//                }
            }

        if (!self.comment.isEmpty) {
            message = message.attachment { builder in
                builder.color(.orange)
                builder.text(self.comment, markdown: true)
            }
        }
        
        return try message.makeChatPostMessage(target: target)
    }
}
