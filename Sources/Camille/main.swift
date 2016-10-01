import Bot
import Sugar

let bot = try SlackBot(
    configDataSource: DefaultConfigDataSource,
    authenticator: OAuthAuthentication.self,
    storage: RedisStorage.self,
    services: [
        CrossPostService(config: CrossPostServiceConfig(
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
        )),
        HelloBot(),
        KarmaBot(options: KarmaBotOptions(
            addText: "++",
            removeText: "--",
            textDistanceThreshold: 4
        )),
        UserJoinService(config: UserJoinConfig(newUserAnnouncement: { im in
            return try SlackMessage()
                .line("Hi, ", im.user, ", welcome to the ios-developer slack team!")
                .makeChatPostMessage(target: im)
        }))
    ]
)

bot.start()
