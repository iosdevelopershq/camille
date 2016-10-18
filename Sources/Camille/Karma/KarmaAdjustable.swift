import Models

protocol KarmaAdjustable {
    var karmaValue: String { get }
}

extension String: KarmaAdjustable {
    var karmaValue: String { return self }
}

extension Emoji: KarmaAdjustable {
    var karmaValue: String {
        return self.emojiSymbol
    }
}
