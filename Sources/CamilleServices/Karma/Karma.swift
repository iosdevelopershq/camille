import ChameleonKit

extension SlackBot {
    public enum Karma {
        enum Keys {
            static let namespace = "Karma"
            static let count = "count"
            static let user = "user"
        }
    }
}

extension SlackBot {
    public func enableKarma(config: Karma.Config, storage: Storage) -> SlackBot {
        listen(for: .message) { bot, message in
            guard message.user != bot.me.id else { return }
            guard !(message.subtype == .thread_broadcast && message.hidden) else { return }

            try Karma.trySenderStatus(storage, bot, message)
            try Karma.tryUserStatus(storage, bot, message)
            try Karma.tryAdjustments(config, storage, bot, message)
            try Karma.tryTop(config, storage, bot, message)
        }

        return self
    }
}
