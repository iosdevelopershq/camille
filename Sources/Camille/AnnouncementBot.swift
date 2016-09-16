import Bot
import Sugar

enum AnnouncementMessage {
    case NewMember
    
    func message(user: User) -> String {
        
        switch self {
        case .NewMember:
            return "Hi \(user.name)! Welcome to the ios-developer slack team!"
        }
    }
}

final class AnnouncementBot: SlackRTMEventService {
    
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
        if let channel: IM = try webApi.execute(imOpenRequest) {
            let message = SlackMessage(target: channel)
                .text(self.announcement().message(user: user))
            
            try webApi.execute(message.apiMethod())
        }
    }
    
    //MARK: - Private
    private func announcement() -> AnnouncementMessage {
        return AnnouncementMessage.NewMember
    }
    
}
