//import Sugar
//
//extension Configs {
//    static let Topic = TopicServiceConfig(
//        userAllowed: { user in
//            return user.is_admin
//        },
//        warning: { channel, user in
//            return try SlackMessage()
//                .line("I can't let you do that, ", user, ". Only admins are allowed to change the topic.")
//                .makeChatPostMessage(target: channel)
//        }
//    )
//}
