import Bot
import Sugar

let bot = try SlackBot(
    configDataSource: DefaultConfigDataSource,
    authenticator: TokenAuthentication.self,
    storage: RedisStorage.self,
    services: [
        HelloBot(),
        KarmaBot(options: KarmaBotOptions(
            targets: ["bot-laboratory"],
            addText: "++",
            removeText: "--",
            textDistanceThreshold: 4
        )),
        TimedMessageService(config: TimedMessageConfig(interval: 3600.0, target: "intro") { target in
            return SlackMessage(target: target)
                .text("Welcome new team members!")
                .apiMethod()
        }),
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
