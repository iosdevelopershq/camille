import Bot
import Sugar
import Foundation

enum KarmaAction {
    case Add
    case Remove
    
    var operation: (Int, Int) -> Int {
        switch self {
        case .Add: return (+)
        case .Remove: return (-)
        }
    }
    
    func randomMessage(user: User, storage: Storage) -> String {
        let count: Int = storage.get(.in("Karma"), key: user.id, or: 0)
        let total = "Total: \(count)"
        
        switch self {
        case .Add: return "\(user.name) you rock! - \(total)"
        case .Remove: return "Boooo \(user.name)! - \(total)"
        }
    }
}

struct KarmaBotOptions {
    let targets: [String]?
    
    let addText: String?
    let addReaction: String?
    let removeText: String?
    let removeReaction: String?
    
    let textDistanceThreshold: Int
    
    init(
        targets: [String]? = nil,
        addText: String? = nil,
        addReaction: String? = nil,
        removeText: String? = nil,
        removeReaction: String? = nil,
        textDistanceThreshold: Int = 4
        ) {
        self.targets = targets
        self.addText = addText
        self.addReaction = addReaction
        self.removeText = removeText
        self.removeReaction = removeReaction
        self.textDistanceThreshold = textDistanceThreshold
    }
}

final class KarmaBot: SlackMessageService {
    //MARK: - Private Properties
    private let options: KarmaBotOptions
    
    //MARK: - Lifecycle
    init(options: KarmaBotOptions) {
        self.options = options
    }
    
    //MARK: - Event Dispatch
    override func configureEvents(slackBot: SlackBot, webApi: WebAPI, dispatcher: SlackRTMEventDispatcher) {
        super.configureEvents(slackBot: slackBot, webApi: webApi, dispatcher: dispatcher)
        dispatcher.onEvent(ReactionAddedEvent.self) { data in
            try self.reaction(
                slackBot: slackBot,
                webApi: webApi,
                reaction: data.reaction,
                user: data.user,
                itemCreator: data.itemCreator,
                target: data.target
            )
        }
        
        //ReactionRemovedEvent //TODO
    }
    
    //MARK: - Event Handlers
    override func message(slackBot: SlackBot, webApi: WebAPI, message: MessageDecorator, previous: MessageDecorator?) throws {
        guard let target = message.target, self.isKarmaChannel(target) else { return }
        
        let response = message
            .mentioned_users
            .flatMap { (user: User) -> (User, KarmaAction)? in
                guard let karma = self.karma(for: user, from: message) else { return nil }
                return (user, karma)
            }
            .map { user, karma in
                self.adjustKarma(of: user, action: karma, storage: slackBot.storage)
                return karma.randomMessage(user: user, storage: slackBot.storage)
            }
            .joined(separator: "\n")
        
        guard !response.isEmpty else { return }
        
        let request = ChatPostMessage(target: target, text: response)
        try webApi.execute(request)
    }
    private func reaction(slackBot: SlackBot, webApi: WebAPI, reaction: String, user: User, itemCreator: User?, target: Target?) throws {
        guard
            let target = target,
            let itemCreator = itemCreator,
            let karma = self.karma(for: itemCreator, fromReaction: reaction),
            user != itemCreator && self.isKarmaChannel(target)
            else { return }
        
        self.adjustKarma(of: itemCreator, action: karma, storage: slackBot.storage)
        
        let request = ChatPostMessage(
            target: target,
            text: karma.randomMessage(user: itemCreator, storage: slackBot.storage)
        )
        try webApi.execute(request)
    }
    
    //MARK: - Private
    private func karma(for user: User, from message: MessageDecorator) -> KarmaAction? {
        let userLink = "<@\(user.id)>"
        
        guard
            message.sender != user,
            let userIndex = message.text.range(of: userLink)?.upperBound
            else { return nil }
        
        if
            let add = self.options.addText,
            let possibleAdd = message.text.range(of: add)?.lowerBound,
            message.text.distance(from: userIndex, to: possibleAdd) <= self.options.textDistanceThreshold { return .Add }
            
        else if
            let remove = self.options.removeText,
            let possibleRemove = message.text.range(of: remove)?.lowerBound,
            message.text.distance(from: userIndex, to: possibleRemove) <= self.options.textDistanceThreshold { return .Remove }
        
        return nil
    }
    private func karma(for user: User, fromReaction reaction: String) -> KarmaAction? {
        if let add = self.options.addReaction, reaction.hasPrefix(add) { return .Add }
        else if let remove = self.options.removeReaction, reaction.hasPrefix(remove) { return .Remove }
        return nil
    }
    private func adjustKarma(of user: User, action: KarmaAction, storage: Storage) {
        do {
            let count: Int = storage.get(.in("Karma"), key: user.id, or: 0)
            
            
//            this line fails vvv
//            try storage.set(.in("Karma"), key: user.id, value: action.operation(count, 1))
//            break it down and see what the failure is
//            also try a simple storage.set(.shared, key: "foo", value: "bar")
            try storage.set(.shared, key: "foo", value: "bar")
            
        } catch let error {
            print("Unable to update Karma: \(error)")
        }
    }
    private func isKarmaChannel(_ target: Target) -> Bool {
        guard let targets = self.options.targets else { return true }
        return targets.contains { $0 == target.name || $0 == "*" }
    }
}
