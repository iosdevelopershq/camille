import Sugar

extension Configs {
    static let Karma = KarmaService.Config(
        topUsersLimit: 20,
        karmaAdjusters: [("++", 1), ("--", -1)],
        textDistanceThreshold: 4,
        allowedBufferCharacters: [" ", ":"],
        positiveMessage: { user, total in
            return ["\(user.name) you rock! - \(total)"]
        },
        negativeMessage: { user, total in
            return ["Boooo \(user.name)! - \(total)"]
        }
    )
}
