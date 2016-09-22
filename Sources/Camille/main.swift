import Bot
import Sugar

let bot = try SlackBot(
    configDataSource: DefaultConfigDataSource,
    authenticator: OAuthAuthentication.self,
    storage: RedisStorage.self,
    services: [
        HelloBot(),
        KarmaBot(options: KarmaBotOptions(
            targets: ["bot-laboratory"],
            addText: "++",
            removeText: "--",
            textDistanceThreshold: 4
        )),
        UserJoinService(config: UserJoinConfig(newUserAnnouncement: { im in
            return SlackMessage(target: im)
                .text("Hi,")
                .user(im.user)
                .text(", welcome to the ios-developer slack team!")
                .apiMethod()
        }))
    ]
)

bot.start()
