import Foundation
import Chameleon
import CamilleServices

let env = Environment()
let dev = try env.get(forKey: "DEVELOPMENT", or: false)

let keyValueStore: KeyValueStore
let storage: Storage

if dev {
    keyValueStore = MemoryKeyValueStore()
    storage = PListStorage()
} else {
    keyValueStore = RedisKeyValueStore(url: try env.get(forKey: "STORAGE_URL"))
    storage = RedisStorage(url: try env.get(forKey: "STORAGE_URL"))
}

let scopes: String = try env.get(forKey: "SCOPES")

let auth = OAuthAuthenticator(
    network: NetworkProvider(),
    storage: storage,
    clientId: try env.get(forKey: "CLIENT_ID"),
    clientSecret: try env.get(forKey: "CLIENT_SECRET"),
    scopes: Set(scopes.components(separatedBy: ",").flatMap(WebAPI.Scope.init)),
    redirectUri: try? env.get(forKey: "REDIRECT_URI")
)

let bot = SlackBot(
    authenticator: auth,
    services: [
        SlackBotHelpService(),
        SlackBotErrorService(store: keyValueStore),
        SlackBotConnectionService(store: keyValueStore),
        HelloService(),
        KarmaService(storage: storage),
        SwiftService(network: NetworkProvider(), token: try env.get(forKey: "GLOT_APIKEY")),
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
