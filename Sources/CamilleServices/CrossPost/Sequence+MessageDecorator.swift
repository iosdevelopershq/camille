//import Sugar
//
//extension Collection where Iterator.Element == MessageDecorator {
//    func addAttachment(with builder: SlackMessageAttachmentBuilder, buttonResponder: SlackInteractiveButtonResponderService, handler: @escaping InteractiveButtonResponseHandler) {
//        guard let message = self.first, let user = message.sender else { return }
//        let channels = self
//            .flatMap { $0.target?.channel }
//            .map { "<#\($0.id)>" }
//            .joined(separator: ", ")
//        
//        builder.field(short: true, title: "User", value: "<@\(user.id)>")
//        builder.field(short: true, title: "Channels", value: channels)
//        builder.field(short: false, title: "Message Preview", value: message.text.substring(to: 50))
//        for button in CrossPostButton.all {
//            builder.button(
//                name: button.rawValue,
//                text: button.text,
//                responder: buttonResponder,
//                handler: handler
//            )
//        }
//    }
//}
