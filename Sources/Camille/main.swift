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
            includeMessage: { message in
                return message.text.components(separatedBy: " ").count > 5
            },
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
        TopicService(config: TopicServiceConfig(
            userAllowed: { user in
                return user.is_admin
            },
            warning: { channel, user in
                return try SlackMessage()
                    .line("I can't let you do that, ", user, ". Only admins are allowed to change the topic.")
                    .makeChatPostMessage(target: channel)
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
