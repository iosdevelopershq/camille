import Chameleon

extension KarmaService {
    func topUsers(bot: SlackBot, message: MessageDecorator, match: PatternMatch) throws {
        let count: Int = try match.value(key: Keys.count)

        guard count > 0 else {
            let response = try message
                .respond()
                .text(["Top", count, "? You must work in QA."])
                .makeChatMessage()

            return try bot.send(response)
        }

        let leaderboard = try storage
            .keys(in: Keys.namespace)
            .map { userId in
                return (ModelPointer<User>(id: userId), try storage.get(key: userId, from: Keys.namespace, or: 0))
            }
            .sorted(by: { $0.1 > $1.1 })

        guard leaderboard.count > 0 else {
            let response = try message
                .respond()
                .text(["No one has any karma yet."])
                .makeChatMessage()

            return try bot.send(response)
        }

        let prefix: String
        if count > config.topUserLimit { prefix = "Yeah, that's too many. Here's the top" }
        else if leaderboard.count < count { prefix = "We only have" }
        else { prefix = "Top" }

        let actualCount = min(count, config.topUserLimit)

        let response = try message
            .respond()
            .text([prefix, actualCount])
            .newLine()

        for (position, entry) in leaderboard.prefix(actualCount).enumerated() {
            try response
                .text(["\(position + 1))", entry.0.value().bold, ": ", entry.1])
                .newLine()
        }
        
        try bot.send(response.makeChatMessage())
    }
}
