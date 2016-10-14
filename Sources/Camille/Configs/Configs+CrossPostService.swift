import Sugar

extension Configs {
    static let CrossPostService = CrossPostServiceConfig(
        timeSpan: 60 * 2,
        reportingTarget: "admins",
        publicWarning: { channel, user in
            return try SlackMessage()
                .line(user, " cross posting is discouraged.")
                .makeChatPostMessage(target: channel)
        },
        privateWarning: { im in
            return try SlackMessage()
                .line("Please refrain from cross posting, it is discouraged here.")
                .makeChatPostMessage(target: im)
        }
    )
}
