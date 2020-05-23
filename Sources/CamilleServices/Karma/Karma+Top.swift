import ChameleonKit

extension SlackBot.Karma {
    static func tryTop(_ config: Config, _ storage: Storage, _ bot: SlackBot, _ message: Message) throws {
        try message.matching(^.user(bot.me) && " top " *> .integer) { count in
            guard count > 0 else {
                try bot.perform(.respond(to: message, .inline, with: "Top \(count)? You must work in QA."))
                return
            }

            let leaderboard = try storage.keys(in: Keys.namespace)
                .map { (Identifier<User>(rawValue: $0), try storage.get(forKey: $0, from: Keys.namespace) as Int) }
                .sorted(by: { $0.1 > $1.1 })

            guard !leaderboard.isEmpty else {
                try bot.perform(.respond(to: message, .inline, with: "No one has any karma yet."))
                return
            }

            let prefix: String
            if count > config.topUserLimit { prefix = "Yeah, that’s too many. Here’s the top" }
            else if leaderboard.count < count { prefix = "We only have" }
            else { prefix = "Top" }

            let actualCount = min(min(count, config.topUserLimit), leaderboard.count)

            var response: [MarkdownString] = [
                "\(prefix) \(actualCount)"
            ]

            for (position, entry) in leaderboard.prefix(actualCount).enumerated() {
                response.append("\(position + 1)) \(entry.0, .bold) : \(entry.1)")
            }

            try bot.perform(.respond(to: message, .inline, with: response.joined(separator: "\n")))
        }
    }
}
