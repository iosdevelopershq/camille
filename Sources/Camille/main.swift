import Chameleon

let env = Environment()
let scopes: String = try env.get(forKey: "SCOPES")
let auth = OAuthAuthenticator(
    network: NetworkProvider(),
    clientId: try env.get(forKey: "CLIENT_ID"),
    clientSecret: try env.get(forKey: "CLIENT_SECRET"),
    scopes: Set(scopes.components(separatedBy: ",").flatMap(WebAPI.Scope.init))
)
let keyValueStore = RedisKeyValueStore(url: try env.get(forKey: "STORAGE_URL"))
let storage = RedisStorage(url: try env.get(forKey: "STORAGE_URL"))

let bot = SlackBot(
    authenticator: auth,
    services: [
        SlackBotHelpService(),
        SlackBotErrorService(store: keyValueStore),
        HelloService(),
        KarmaService(storage: storage)
    ]
)

func debug(_ message: String) {
    let chatMessage = ChatMessage(
        channel: "U04UAVAEB", // @iankeen
        text: message
    )

    try? bot.send(chatMessage)
}

bot.start()
