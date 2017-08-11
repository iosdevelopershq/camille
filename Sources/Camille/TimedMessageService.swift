//import Bot
//import Sugar
//import Foundation
//
//struct TimedMessageConfig {
//    let interval: TimeInterval
//    let target: String
//    let announcement: (SlackTargetType) throws -> ChatPostMessage
//}
//
//final class TimedMessageService: SlackRTMEventService {
//    private let config: TimedMessageConfig
//    private var timer: TimerService?
//    
//    //MARK: - Lifecycle
//    init(config: TimedMessageConfig) {
//        self.config = config
//    }
//    
//    //MARK: - Event Dispatch
//    func configureEvents(slackBot: SlackBot, webApi: WebAPI, dispatcher: SlackRTMEventDispatcher) {
//        self.timer = TimerService(id: "timedMessage", interval: self.config.interval, storage: slackBot.storage, dispatcher: dispatcher) { _ in
//            try self.pongEvent(slackBot: slackBot, webApi: webApi)
//        }
//    }
//    func pongEvent(slackBot: SlackBot, webApi: WebAPI) throws {
//        let data = slackBot.currentSlackModelData()
//        guard let channel = data.channels.filter({ $0.name == config.target }).first
//            else { return }
//        
//        let message = try config.announcement(channel)
//        
//        try webApi.execute(message)
//    }
//}
