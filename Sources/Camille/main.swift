import Foundation
import CamilleServices
import ChameleonKit
import VaporProviders

let env = Environment()

let keyValueStore: KeyValueStorage
let storage: Storage

#if !os(Linux)
keyValueStore = MemoryKeyValueStorage()
storage = PListStorage(name: "camille")
#else
keyValueStore = RedisKeyValueStorage(url: try env.get(forKey: "STORAGE_URL"))
storage = RedisStorage(url: try env.get(forKey: "STORAGE_URL"))
#endif

let bot = try SlackBot
    .vaporBased(
        verificationToken: try env.get(forKey: "VERIFICATION_TOKEN"),
        accessToken: try env.get(forKey: "ACCESS_TOKEN")
    )
    .enableHello()
    .enableKarma(config: .default(), storage: storage)

try bot.start()
