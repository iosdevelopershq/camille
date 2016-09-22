import Bot
import Sugar
import Foundation

struct TimedMessageConfig {
    let interval: TimeInterval
    let target: String
    let announcement: (SlackTargetType) -> ChatPostMessage
}

final class TimedMessageService: SlackRTMEventService {
    private let config: TimedMessageConfig
    
    //MARK: - Lifecycle
    init(config: TimedMessageConfig) {
        self.config = config
    }
    
    //MARK: - Event Dispatch
    func configureEvents(slackBot: SlackBot, webApi: WebAPI, dispatcher: SlackRTMEventDispatcher) {
        dispatcher.onEvent(pong.self) { data in
            guard let timestamp = data["timestamp"] as? Int else { return }
            
            try self.pongEvent(slackBot: slackBot, webApi: webApi, timestamp: TimeInterval(timestamp))
        }
    }
    func pongEvent(slackBot: SlackBot, webApi: WebAPI, timestamp: TimeInterval) throws {
        let previous: TimeInterval = slackBot.storage.get(.in("Announcements"), key: "previousTimeStamp", or: 0)
        if (timestamp - previous) >= config.interval {
            try slackBot.storage.set(.in("Announcements"), key: "previousTimeStamp", value: timestamp)
            let data = slackBot.currentSlackModelData()
            guard let channel = data.channels.filter({ $0.name == config.target }).first
                else { return }
            
            let message = config.announcement(channel)
            
            try webApi.execute(message)
        }
    }
}

extension Double: StorableType {
    public var stringValue: String {
        return String(self)
    }
    public static func makeValue(from string: String) throws -> Double {
        guard let value = Double(string) else { throw StorageError.invalidValue(value: string) }
        return value
    }
}
