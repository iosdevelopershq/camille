import Foundation
import Models

extension Message {
    static func from(_ userId: String, `in` channelId: String, saying text: String) -> [String: Any] {
        return [
            "type": "message",
            "ts": "\(Date().timeIntervalSince1970)",
            "text": text,
            "channel": "\(channelId)",
            "user": "\(userId)",
        ]
    }
}
