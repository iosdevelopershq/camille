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

struct KarmaServiceOptions {
    let targets: [String]?
    
    let addText: String?
    let addReaction: String?
    let removeText: String?
    let removeReaction: String?
    
    let textDistanceThreshold: Int
    let allowedBufferCharacters: Set<Character>
    
    init(
        targets: [String]? = nil,
        addText: String? = nil,
        addReaction: String? = nil,
        removeText: String? = nil,
        removeReaction: String? = nil,
        textDistanceThreshold: Int = 4,
        allowedBufferCharacters: Set<Character> = [" ", ":"]
        ) {
        self.targets = targets
        self.addText = addText
        self.addReaction = addReaction
        self.removeText = removeText
        self.removeReaction = removeReaction
        self.textDistanceThreshold = textDistanceThreshold
        self.allowedBufferCharacters = allowedBufferCharacters
    }
}

final class KarmaService: SlackMessageService {
    //MARK: - Private Properties
    private let options: KarmaServiceOptions
    private let config: Config
    
    //MARK: - Lifecycle
    init(options: KarmaServiceOptions) {
        self.options = options
        
        let config = try! Config(
            supportedItems: AllConfigItems(),
            source: DefaultConfigDataSource
        )
        self.config = config
    }
    
    //MARK: - Event Dispatch
    func configureEvents(slackBot: SlackBot, webApi: WebAPI, dispatcher: SlackRTMEventDispatcher) {
        self.configureMessageEvent(slackBot: slackBot, webApi: webApi, dispatcher: dispatcher)
        dispatcher.onEvent(reaction_added.self) { data in
            try self.reactionEvent(
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
    func messageEvent(slackBot: SlackBot, webApi: WebAPI, message: MessageDecorator, previous: MessageDecorator?) throws {
        guard let target = message.target, self.isKarmaChannel(target) else { return }
        
        let response: String
        
        if message.text.lowercased().hasPrefix(self.topKarmaCommand(bot: slackBot)) { // Top karma users command
            if
                let listCountText = message.text
                    .substring(from: topKarmaCommand(bot: slackBot).characters.count)
                    .components(separatedBy: " ").filter({ $0.characters.count != 0 }).first,
                let listCount = Int(listCountText)
            {
                response = topKarma(maxList: listCount, in: slackBot.storage)
            } else {
                response = "Top what?"
            }
        } else { // No command found, try to find karma action
            response = message
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
        }
        
        guard !response.isEmpty else { return }
        
        let request = ChatPostMessage(target: target, text: response)
        try webApi.execute(request)
    }
    private func reactionEvent(slackBot: SlackBot, webApi: WebAPI, reaction: String, user: User, itemCreator: User?, target: SlackTargetType?) throws {
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
            message.text.distance(from: userIndex, to: possibleAdd) <= self.options.textDistanceThreshold,
            message.text.substring(with: userIndex..<possibleAdd).contains(only: self.options.allowedBufferCharacters) { return .Add }
            
        else if
            let remove = self.options.removeText,
            let possibleRemove = message.text.range(of: remove)?.lowerBound,
            message.text.distance(from: userIndex, to: possibleRemove) <= self.options.textDistanceThreshold,
            message.text.substring(with: userIndex..<possibleRemove).contains(only: self.options.allowedBufferCharacters){ return .Remove }
        
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
            try storage.set(.in("Karma"), key: user.id, value: action.operation(count, 1))
            
        } catch let error {
            print("Unable to update Karma: \(error)")
        }
    }
    private func isKarmaChannel(_ target: SlackTargetType) -> Bool {
        guard let targets = self.options.targets else { return true }
        return targets.contains { $0 == target.name || $0 == "*" }
    }
    private func topKarmaCommand(bot: SlackBot, isDirectMessage: Bool = false) -> String {
        return isDirectMessage ? "top" : "<@\(bot.me.id.lowercased())> top"
    }
    private func topKarma(maxList: Int, in storage: Storage) -> String {
        guard maxList > 0 else { return "Top \(maxList)? You must work in QA." }
        
        func karma(for user: String) -> Int {
            return storage.get(in: .in("Karma"), key: user, or: 0)
        }
        
        let users = storage.allKeys(.in("Karma"))
            .map { (name: $0, karma: karma(for: $0)) }
            .sorted(by: { $0.karma > $1.karma })
            
        let responsePrefix: String
        let numberToShow: Int
        
        if maxList > 20 {
            numberToShow = max(users.count, 20)
            responsePrefix = "Yeah, that's too many. Here's the top"
        } else if maxList > users.count {
            numberToShow = users.count
            responsePrefix = "We only have"
        } else {
            numberToShow = maxList
            responsePrefix = "Top"
        }
        
        let list = users
            .prefix(numberToShow)
            .map { user in "<@\(user.name)>: \(user.karma)" }
            .joined(separator: "\n")
        
        return "\(responsePrefix) \(numberToShow):\n\(list)"
    }
}
