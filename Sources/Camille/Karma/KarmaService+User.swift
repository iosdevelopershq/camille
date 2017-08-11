import Chameleon

extension KarmaService {
    func userCount(bot: SlackBot, message: MessageDecorator, match: PatternMatch) throws {
        let user: ModelPointer<User> = try match.value(key: Keys.user)

        let count = try storage.get(key: user.id, from: Keys.namespace, or: 0)

        let response = try message
            .respond()
            .text(count == 0
                ? ["It doesn't look like", user, "has any karma yet"]
                : [user, "has", count, "karma"]
            )

        try bot.send(response.makeChatMessage())
    }

    func senderCount(bot: SlackBot, message: MessageDecorator, match: PatternMatch) throws {
        let count = try storage.get(key: message.sender().id, from: Keys.namespace, or: 0)

        let response = try message
            .respond()
            .text(count == 0
                ? ["It doesn't look like you have any karma yet"]
                : ["You have", count, "karma"]
        )

        try bot.send(response.makeChatMessage())
    }
}
