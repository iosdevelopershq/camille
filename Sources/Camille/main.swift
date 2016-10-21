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
        CrossPostService(config: Configs.CrossPostService),
        TopicService(config: Configs.TopicService),
        HelloService(),
        KarmaService(options: Configs.KarmaService),
        UserJoinService(config: Configs.UserJoinService)
    ]
)

bot.start()
