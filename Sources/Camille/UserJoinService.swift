import Bot
import Sugar

final class UserJoinService: SlackRTMEventService {
    private let newUserAnnouncement: (IM) throws -> ChatPostMessage
    
    //MARK: - Lifecycle
    init(newUserAnnouncement: @escaping (IM) throws -> ChatPostMessage) {
        self.newUserAnnouncement = newUserAnnouncement
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
        let message = try self.newUserAnnouncement(channel)
        
        try webApi.execute(message)
    }
}
