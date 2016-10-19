import Bot
import Sugar

class KarmaService: SlackMessageService {
    //MARK: - Properties
    let config: Config
    
    //MARK: - Lifecycle
    init(config: Config) {
        self.config = config
    }
    
    //MARK: - Routing
    func messageEvent(slackBot: SlackBot, webApi: WebAPI, message: MessageDecorator, previous: MessageDecorator?) throws {
        guard let sender = message.sender, let target = message.target else { return }
        
        let isDirectMessage = message.message.channel?.value.instantMessage != nil
        
        //Top Users
        let showTopUsers = self.showTopUsers(from: slackBot.storage, in: target, with: webApi, users: slackBot.currentSlackModelData().users)
        
        if isDirectMessage {
            try message.routeText(
                to: showTopUsers,
                matching: String.any, "top", Int.any(name: "count")
            )
        } else {
            try message.routeText(
                to: showTopUsers,
                matching: slackBot.me, String.any, "top", Int.any(name: "count")
            )
        }
        
        //Users Karma
        try message.routeText(
            to: self.showUserKarma(user: sender, from: slackBot.storage, in: target, with: webApi),
            allowingRemainder: true,
            matching: slackBot.me, "how much karma do i have"
        )
        
        //Karma Action
        try self.adjustKarma(in: message, from: sender, in: target, storage: slackBot.storage, webApi: webApi)
    }
}
