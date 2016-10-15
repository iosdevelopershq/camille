import Bot
import Sugar
import Foundation

final class TimedMessageService: SlackRTMEventService {
    //MARK: - Properties
    private var timer: TimerService?
    private let interval: TimeInterval
    private let target: String
    private let announcement: (SlackTargetType) throws -> ChatPostMessage
    
    //MARK: - Lifecycle
    init(interval: TimeInterval, target: String, announcement: @escaping (SlackTargetType) throws -> ChatPostMessage) {
        self.interval = interval
        self.target = target
        self.announcement = announcement
    }
    
    //MARK: - Event Dispatch
    func configureEvents(slackBot: SlackBot, webApi: WebAPI, dispatcher: SlackRTMEventDispatcher) {
        self.timer = TimerService(id: "timedMessage", interval: self.interval, storage: slackBot.storage, dispatcher: dispatcher) { _ in
            try self.pongEvent(slackBot: slackBot, webApi: webApi)
        }
    }
    func pongEvent(slackBot: SlackBot, webApi: WebAPI) throws {
        let data = slackBot.currentSlackModelData()
        guard
            let channel = data.channels.first(where: { $0.name == target })
            else { return }
        
        let message = try announcement(channel)
        
        try webApi.execute(message)
    }
}
