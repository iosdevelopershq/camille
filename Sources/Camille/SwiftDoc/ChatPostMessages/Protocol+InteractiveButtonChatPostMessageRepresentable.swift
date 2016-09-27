import Bot
import Sugar
import Models

extension Protocol: InteractiveButtonChatPostMessageRepresentable {
    public func makeInteractiveButtonChatPostMessage(target: SlackTargetType, responder: SlackInteractiveButtonResponderService, handler: @escaping (InteractiveButtonResponse) throws -> Void) throws -> ChatPostMessage {
        
        let message = SlackMessage()
            .line("Details of: ", self.name.bold)
            .attachment { builder in
                builder.color(.orange)
                
                let buttonMap: [String: [Any]] = [
                    "Inits": self.inits,
                    "Functions": self.functions,
                    "Properties": self.properties,
                    "Subscripts": self.subscripts,
                    "Operators": self.operators,
                    "Aliases": self.aliases,
                    "Inherits": self.inherits,
                    "Inherited": self.allInherited,
                    ]
                
                let buttons: [String] = buttonMap.flatMap { item -> String? in
                    return (item.value.isEmpty ? nil : item.key)
                }
                
                builder.field(short: true, title: "Type", value: self.kind)
                for button in buttons {
                    builder.button(name: button, text: button, responder: responder, handler: handler)
                }
            }
            .attachment { builder in
                builder.color(.orange)
                builder.text(self.comment, markdown: true)
            }
        
        return try message.makeChatPostMessage(target: target)
    }
}
