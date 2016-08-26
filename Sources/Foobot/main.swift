import Bot

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
            ))
    ]
)

bot.start()
