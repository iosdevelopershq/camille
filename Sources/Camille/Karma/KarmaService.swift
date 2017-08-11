import Chameleon

final class KarmaService: SlackBotMessageService {
    // MARK: - Properties
    let storage: Storage
    let config: Config

    enum Keys {
        static let namespace = "Karma"
        static let count = "count"
        static let user = "user"
    }

    // MARK: - Lifecycle
    init(config: Config = Config.default(), storage: Storage) {
        self.config = config
        self.storage = storage
    }

    // MARK: - Public Functions
    func configure(slackBot: SlackBot) {
        configureMessageService(slackBot: slackBot)

        slackBot
            .registerHelp(item: Patterns.topUsers)
            .registerHelp(item: Patterns.myCount)
            .registerHelp(item: Patterns.userCount)
            .registerHelp(item: Patterns.adjustment)
    }
    func onMessage(slackBot: SlackBot, message: MessageDecorator, previous: MessageDecorator?) throws {
        try slackBot
            .route(message, matching: Patterns.topUsers, to: topUsers)
            .route(message, matching: Patterns.myCount, to: senderCount)
            .route(message, matching: Patterns.userCount, to: userCount)
            .route(message, matching: Patterns.adjustment, to: noop)

        try adjust(bot: slackBot, message: message)
    }

    private func noop(bot: SlackBot, message: MessageDecorator, match: PatternMatch) throws { }
}
