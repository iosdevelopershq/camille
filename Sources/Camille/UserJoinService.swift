import Bot
import Sugar

struct UserJoinConfig {
    let newUserAnnouncement: (IM) throws -> ChatPostMessage
}

final class UserJoinService: SlackRTMEventService {
    private let config: UserJoinConfig
    
    //MARK: - Lifecycle
    init(config: UserJoinConfig) {
        self.config = config
    }
    
    //MARK: - Event Dispatch
    func configureEvents(slackBot: SlackBot, webApi: WebAPI, dispatcher: SlackRTMEventDispatcher) {
        dispatcher.onEvent(team_join.self) { user in
            try self.teamJoinEvent(slackBot: slackBot,
                                   webApi: webApi,
                                   user: user)
        }
    }
    func teamJoinEvent(slackBot: SlackBot, webApi: WebAPI, user: User) throws {
        guard !user.is_bot else { return }
        
        let imOpenRequest = IMOpen(user: user)
        let channel = try webApi.execute(imOpenRequest)
        let message = try config.newUserAnnouncement(channel)
        
        try webApi.execute(message)
    }
}
