import Chameleon

private let greetings = ["heya", "hey", "hi", "hello", "gday", "howdy"]

public final class HelloService: SlackBotMessageService {
    public init() { }

    public func configure(slackBot: SlackBot) {
        configureMessageService(slackBot: slackBot)

        slackBot.registerHelp(item: Patterns.greeting(slackBot))
    }
    public func onMessage(slackBot: SlackBot, message: MessageDecorator, previous: MessageDecorator?) throws {
        try slackBot.route(message, matching: Patterns.greeting(slackBot), to: sendGreeting)
    }

    private func sendGreeting(bot: SlackBot, message: MessageDecorator, match: PatternMatch) throws -> Void {
        let response = try message
            .respond()
            .text(["well", try match.value(key: "greeting"), "back at you", try message.sender()])
            .makeChatMessage()

        try bot.send(response)
        try bot.react(to: message, with: Emoji.wave)
    }
}

private enum Patterns: HelpRepresentable {
    case greeting(SlackBot)

    var topic: String {
        return "Greetings"
    }
    var description: String {
        return "Greet the bot"
    }

    var pattern: [Matcher] {
        switch self {
        case .greeting(let bot): return [greetings.any.using(key: "greeting"), bot.me]
        }
    }
}
