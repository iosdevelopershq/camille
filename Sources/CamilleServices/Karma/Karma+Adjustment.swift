import ChameleonKit

struct KarmaModifier {
    let update: (Int) -> Int
}

extension ElementMatcher {
    static var karma: ElementMatcher {
        let plusOne = ElementMatcher(^"++").map(KarmaModifier { $0 + 1 })
        let plusN = ElementMatcher("+=" && optional(.whitespace) *> .integer).map { n in KarmaModifier { $0 + n } }

        let minusOne = ElementMatcher(^"--").map(KarmaModifier { $0 - 1 })
        let minusN = ElementMatcher("-=" && optional(.whitespace) *> .integer).map { n in KarmaModifier { $0 - n } }

        return plusOne || plusN || minusOne || minusN
    }
}

extension SlackBot.Karma {
    static func tryAdjustments(_ config: Config, _ storage: Storage, _ bot: SlackBot, _ message: Message) throws {
        typealias KarmaMatch = (Identifier<User>, KarmaModifier)

        try message.richText().matchingAll([.user, .karma]) { (updates: [KarmaMatch]) in
            // consolidate any updates for the same user
            var tally: [Identifier<User>: Int] = [:]

            for update in updates {
                let current = tally[update.0, default: 0]
                tally[update.0] = update.1.update(current)
            }

            // filter out unwanted results
            tally[message.user] = 0 // remove any 'self-karma'
            let validUpdates = tally.filter({ $0.value != 0 }).keys

            guard !validUpdates.isEmpty else { return }

            // perform updates and build response
            var responses: [MarkdownString] = []
            for user in validUpdates {
                let newTotal: Int
                let birthday: Bool

                do {
                    let currentTotal: Int = try storage.get(forKey: user.rawValue, from: Keys.namespace)
                    newTotal = currentTotal + tally[user]!
                    birthday = false

                }  catch StorageError.missing {
                    newTotal = tally[user]!
                    birthday = true
                }

                try storage.set(forKey: user.rawValue, from: Keys.namespace, value: newTotal)

                let commentFormatter = (tally[user]! > 0
                    ? config.positiveComments.randomElement().map(withBirthday(birthday))
                    : config.negativeComments.randomElement().map(withBirthday(birthday))
                ) ?? { "\($0): \($1)" }

                responses.append(commentFormatter(user, newTotal))
            }

            try bot.perform(.respond(to: message, .inline, with: responses.joined(separator: "\n")))
        }
    }
}

private func withBirthday(_ birthday: Bool) -> (@escaping SlackBot.Karma.CommentsFormatter) -> SlackBot.Karma.CommentsFormatter {
    return { original in
        let birthdayPrefix: MarkdownString = "\(.balloon) "

        return birthday
            ?  { birthdayPrefix.appending(original($0, $1)) }
            : original
    }
}
