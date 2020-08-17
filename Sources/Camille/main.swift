import Foundation
import CamilleServices
import ChameleonKit
import VaporProviders
import LegibleError

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
    .enableEarlyWarning(config: .default())

bot.listen(for: .error) { bot, error in
    let channel = Identifier<Channel>(rawValue: "#camille_errors")
    try bot.perform(.speak(in: channel, "\("Error: ", .bold)"))
    try bot.perform(.upload(channels: [channel], filetype: .javascript, Data(error.legibleLocalizedDescription.utf8)))
}


let errorChannel = Identifier<Channel>(rawValue: "G015J4U0SUC")

extension SlackEvent {
    static var all: SlackEvent<[String: Any]> {
        return .init(
            identifier: "any",
            canHandle: { type, json in
                switch type {
                case "message":
                    return (json["channel"] as? String) != errorChannel.rawValue
                default:
                    return true
                }
            },
            handler: { $0 }
        )
    }
}

var dumping = false
bot.listen(for: .message) { bot, message in
    guard message.channel == errorChannel else { return }

    try message.matching(^.user(bot.me) && " start") { dumping = true }
    try message.matching(^.user(bot.me) && " stop") { dumping = false }
}

bot.listen(for: .all) { (bot, json) in
    guard dumping else { return }
    let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    let string = String(data: data, encoding: .utf8) ?? ""

    guard !string.isEmpty else { return }

    try bot.perform(.speak(in: errorChannel, "\(string)"))
}

try bot.start()
