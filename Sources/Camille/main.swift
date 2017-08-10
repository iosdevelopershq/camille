import Bot
import Sugar

#if os(Linux)
let StorageProvider = RedisStorage.self
#else
let StorageProvider = PlistStorage.self
#endif

let bot = try SlackBot(
    configDataSource: DefaultConfigDataSource,
    authenticator: TokenAuthentication.self,
    storage: StorageProvider,
    services: [
        //CrossPostService(config: Configs.CrossPost),
        //TopicService(config: Configs.Topic),
        HelloService(),
        KarmaService(config: Configs.Karma),
        //UserJoinService(config: Configs.UserJoin)
    ]
)

bot.start()
