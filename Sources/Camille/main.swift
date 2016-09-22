import Bot
import Sugar

let bot = try SlackBot(
    configDataSource: DefaultConfigDataSource,
    authenticator: TokenAuthentication.self,
    storage: MemoryStorage.self,
    services: [
        SwiftDocService(),
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
