import Bot
import Sugar

struct AnnouncerConfig {
    let newUserAnnouncement: (IM) -> ChatPostMessage
}

final class AnnouncementService: SlackRTMEventService {
    private let config: AnnouncerConfig
    
    //MARK: - Lifecycle
    init(config: AnnouncerConfig) {
        self.config = config
    }
    
    //MARK: - Event Dispatch
    func configureEvents(slackBot: SlackBot, webApi: WebAPI, dispatcher: SlackRTMEventDispatcher) {
        dispatcher.onEvent(team_join.self) { (user) in
            try self.teamJoinEvent(slackBot: slackBot,
                                   webApi: webApi,
                                   user: user)
        }
    }
    func teamJoinEvent(slackBot: SlackBot, webApi: WebAPI, user: User) throws {
        guard !user.is_bot else { return }
        
        let imOpenRequest = IMOpen(user: user)
        let channel = try webApi.execute(imOpenRequest)
        let message = config.newUserAnnouncement(channel)
        
        try webApi.execute(message)
    }
}
