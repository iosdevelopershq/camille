import Chameleon
import Foundation

private typealias PartialUpdate = (user: ModelPointer<User>, operation: Operation)
private typealias Update = (ModelPointer<User>, (current: Int, change: Int))

private enum Operation: String {
    case plus = "++"
    case minus = "--"

    func update(value: Int) -> Int {
        switch self {
        case .plus: return value + 1
        case .minus: return value - 1
        }
    }
}

extension KarmaService {
    func adjust(bot: SlackBot, message: MessageDecorator) throws {
        guard !message.isIM else { return }

        func partialUpdate(from link: MessageDecorator.Link<ModelPointer<User>>) throws -> PartialUpdate? {
            guard try link.value.id != message.sender().id else { return nil }

            let possibleOperation = message.text
                .substring(from: link.range.upperBound)
                .trimCharacters(in: [" ", ">", ":"])
                .components(separatedBy: " ")
                .first ?? ""

            guard let operation = Operation(rawValue: possibleOperation)
                else { return nil }

            return (link.value, operation)
        }

        func consolidatePartialUpdates(for user: ModelPointer<User>, partials: [PartialUpdate]) throws -> Update {
            let count: Int = try storage.get(key: user.id, from: Keys.namespace, or: 0)
            let change = partials.reduce(0) { $1.operation.update(value: $0) }
            return (user, (count, change))
        }

        let updates = try message
            .mentionedUsers
            .flatMap(partialUpdate)
            .group(by: { $0.user })
            .map(consolidatePartialUpdates)
            .filter { $0.value.change != 0 }

        guard !updates.isEmpty else { return }

        let response = try message.respond()

        for (user, data) in updates {
            let newTotal = data.current + data.change
            storage.set(value: newTotal, forKey: user.id, in: Keys.namespace)

            let comment = (data.change > 0
                ? config.positiveComments.randomElement
                : config.negativeComments.randomElement
            ) ?? ""

            response
                .text([user, comment, newTotal])
                .newLine()
        }
        
        try bot.send(response.makeChatMessage())
    }
}
