import ChameleonKit

extension SlackBot.Karma {
    static func trySenderStatus(_ storage: Storage, _ bot: SlackBot, _ message: Message) throws {
        try message.richText().matching([^.user(bot.me), "how much karma do I have"]) {
            let count = try storage.get(forKey: message.user.rawValue, from: Keys.namespace, or: 0)

            let response: MarkdownString = count == 0
                ? "It doesn’t look like you have any karma yet"
                : "You have \(count) karma"

            try bot.perform(.respond(to: message, .inline, with: response))
        }
    }

    static func tryUserStatus(_ storage: Storage, _ bot: SlackBot, _ message: Message) throws {
        try message.richText().matching([^.user(bot.me), "how much karma does", .user, "have"]) { (_: Identifier<User>, user: Identifier<User>) in
            let count = try storage.get(forKey: user.rawValue, from: Keys.namespace, or: 0)

            let response: MarkdownString = count == 0
                ? "It doesn’t look like you have any karma yet"
                : "You have \(count) karma"

            try bot.perform(.respond(to: message, .inline, with: response))
        }
    }
}
