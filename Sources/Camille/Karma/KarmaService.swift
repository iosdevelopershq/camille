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
        
        let isDirectMessage = message.message.channel?.instantMessage != nil
        
        //Top Users
        /*
        let topUserPattern = (isDirectMessage
            ? [String.any, "top", Int.any(name: "count")]
            : [slackBot.me, String.any, "top", Int.any(name: "count")]
        )
        try message.routeText(
            to: self.showTopUsers(
                from: slackBot.storage,
                in: target,
                with: webApi,
                users: slackBot.currentSlackModelData().users
            ),
            matching: topUserPattern
        )
        */
        
        //Users Karma
        let userKarmaPattern: [PartialPatternMatcher] = (isDirectMessage
            ? ["how much karma do i have"]
            : [slackBot.me, "how much karma do i have"]
        )
        try message.routeText(
            to: self.showUserKarma(user: sender, from: slackBot.storage, in: target, with: webApi),
            allowingRemainder: true,
            matching: userKarmaPattern
        )
        
        //Karma Action
        guard !isDirectMessage else { return }
        try self.adjustKarma(in: message, from: sender, in: target, storage: slackBot.storage, webApi: webApi)
    }
}
