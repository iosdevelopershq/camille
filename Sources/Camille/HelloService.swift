import Chameleon

final class HelloService: SlackBotMessageService {
    func configure(slackBot: SlackBot) {
        configureMessageService(slackBot: slackBot)

        slackBot.registerHelp(item: Patterns.greeting(slackBot))
    }
    func onMessage(slackBot: SlackBot, message: MessageDecorator, previous: MessageDecorator?) throws {
        try slackBot.route(message, matching: Patterns.greeting(slackBot), to: sendGreeting)
    }

    private func sendGreeting(bot: SlackBot, message: MessageDecorator, match: PatternMatch) throws -> Void {
        let response = try message
            .respond()
            .text(["well", try match.value(key: "greeting"), "back at you", try message.sender()])
            .makeChatMessage()

        try bot.send(response)
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
        case .greeting(let bot): return [["hey", "hi", "hello"].any.using(key: "greeting"), bot.me]
        }
    }
}
