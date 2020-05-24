import Foundation
import CamilleServices
import ChameleonKit
import VaporProviders

extension Error {
    var displayDescription: String {
        switch self {
        case let error as LocalizedError:
            return error.localizedDescription

        case let error as CustomNSError:
            return error.localizedDescription

        default:
            return (self as NSError).localizedDescription
        }
    }
}

let env = Environment()

let keyValueStore: KeyValueStorage
let storage: Storage

#if !os(Linux)
keyValueStore = MemoryKeyValueStorage()
storage = PListStorage(name: "camille")
#else
let storageUrl = URL(string: try env.get(forKey: "STORAGE_URL"))!
keyValueStore = RedisKeyValueStorage(url: storageUrl)
storage = RedisStorage(url: storageUrl)
#endif

let bot = try SlackBot
    .vaporBased(
        verificationToken: try env.get(forKey: "VERIFICATION_TOKEN"),
        accessToken: try env.get(forKey: "ACCESS_TOKEN")
    )
    .enableHello()
    .enableKarma(config: .default(), storage: storage)

bot.listen(for: .error) { bot, error in
    let channel = Identifier<Channel>(rawValue: "#bot-laboratory")
    try bot.perform(.speak(in: channel, "\("Error: ", .bold) \(error.legibleLocalizedDescription)"))
}

try bot.start()
