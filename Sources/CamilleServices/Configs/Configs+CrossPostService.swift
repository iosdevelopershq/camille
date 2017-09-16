//import Sugar
//
//extension Configs {
//    static let CrossPost = CrossPostServiceConfig(
//        timeSpan: 60 * 2,
//        includeMessage: { message in
//            return message.text.components(separatedBy: " ").count > 5
//        },
//        reportingTarget: "admins",
//        publicWarning: { channel, user in
//            return try SlackMessage()
//                .line(user, " cross posting is discouraged.")
//                .makeChatPostMessage(target: channel)
//        },
//        privateWarning: { im in
//            return try SlackMessage()
//                .line("Please refrain from cross posting, it is discouraged here.")
//                .makeChatPostMessage(target: im)
//        }
//    )
//}
