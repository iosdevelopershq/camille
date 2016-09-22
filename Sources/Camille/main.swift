import Bot
import Sugar

let bot = try SlackBot(
    configDataSource: DefaultConfigDataSource,
    authenticator: OAuthAuthentication.self,
    storage: RedisStorage.self,
    services: [
        AnnouncementService(config: AnnouncerConfig { im in
            return SlackMessage(target: im)
                .text("Hi,")
                .user(im.user)
                .text(", welcome to the ios-developer slack team!")
                .apiMethod()
        }),
        HelloBot(),
        KarmaBot(options: KarmaBotOptions(
            addText: "++",
            removeText: "--",
            textDistanceThreshold: 4
        ))
    ]
)

bot.start()
