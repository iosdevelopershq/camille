import Bot
import Sugar

#if os(Linux)
let StorageProvider = RedisStorage.self
#else
let StorageProvider = PlistStorage.self
#endif

let bot = try SlackBot(
    configDataSource: DefaultConfigDataSource,
    authenticator: OAuthAuthentication.self,
    storage: StorageProvider,
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
        HelloService(),
        KarmaService(options: KarmaServiceOptions(
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
