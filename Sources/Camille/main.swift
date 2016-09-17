import Bot
import Sugar

let bot = try SlackBot(
    configDataSource: DefaultConfigDataSource,
    authenticator: TokenAuthentication.self,
    storage: RedisStorage.self,
    services: [
        AnnouncementBot(config: AnnouncerConfig { im -> ChatPostMessage in
            return SlackMessage(target: im)
                .text("Hi")
                .user(im.user)
                .text("Welcome to the ios-developer slack team!")
                .apiMethod()
        }),
        HelloBot(),
        KarmaBot(options: KarmaBotOptions(
            targets: ["bot-laboratory"],
            addText: "++",
            removeText: "--",
            textDistanceThreshold: 4
        ))
    ]
)

bot.start()
