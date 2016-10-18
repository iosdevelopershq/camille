import Sugar

extension Configs {
    static let UserJoin = UserJoinConfig(newUserAnnouncement: { im in
        return try SlackMessage()
            .line("Hi, ", im.user, ", welcome to the ios-developer slack team!")
            .makeChatPostMessage(target: im)
    })
}
