import Bot
import Sugar
import Models


extension Type: InteractiveButtonChatPostMessageRepresentable {
    public func makeInteractiveButtonChatPostMessage(target: SlackTargetType, responder: SlackInteractiveButtonResponderService, handler: @escaping (InteractiveButtonResponse) throws -> Void) throws -> ChatPostMessage {
        
        let message = SlackMessage()
            .line("Details of:", self.name.capitalized.bold)
            .attachment { builder in
                
                let buttonMap: [String: [Any]] = [
                    "Inits": self.inits,
                    "Functions": self.functions,
                    "Properties": self.properties,
                    "Subscripts": self.subscripts,
                    "Inherits": self.allInherits,
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
//            .attachment { builder in
//                //comment
//        }
        
        return try message.makeChatPostMessage(target: target)
    }
}
