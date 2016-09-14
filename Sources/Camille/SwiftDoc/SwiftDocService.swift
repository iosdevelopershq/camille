import Bot
import Sugar
import Foundation

protocol SwiftDocModelType: DictionaryRepresentable, StringRepresentable {
    static func make(from json: [String: Any]) throws -> Self
}

protocol ChatPostMessageRepresentable {
    func makeChatPostMessage(target: SlackTargetType) -> ChatPostMessage
}

let EmptySlackModels: SlackModels = (
    users: [],
    channels: [],
    groups: [],
    ims: [],
    team: nil
)

extension Array: DefaultableType {
    public static var `default`: Array<Element> { return [] }
}

enum SwiftDocModel: String {
    case `operator`
    case `protocol`
    case `struct`
    case `class`
    case `enum`
    //case `extension`
    case operator_func
    case `func`
    case `init_`
    case `deinit`
    case `subscript`
    case `typealias`
    case `case`
    case `var`
    
    var modelType: SwiftDocModelType.Type {
        switch self {
        case .operator: return Operator.self
        case .protocol: return Protocol.self
        case .struct, .class, .enum: return Type.self
        //case .extension: return Extension.self
        case .operator_func: return OperatorFunction.self
        case .func: return Function.self
        case .init_: return Init.self
        case .deinit: return Deinit.self
        case .subscript: return Subscript.self
        case .typealias: return Typealias.self
        case .case: return Case.self
        case .var: return Property.self
        }
    }
    
    init?(json: [String: Any]) {
        guard let type = json["kind"] as? String else { return nil }
        
        let rawValueString = type.components(separatedBy: "_").joined(separator: " ")
        guard let result = SwiftDocModel(rawValue: rawValueString) else { return nil }
        
        self = result
    }
}

class SwiftDocService: SlackMessageService, SlackConnectionService {
    private var sync: SwiftDocSync?
    
    func connected(slackBot: SlackBot, botUser: BotUser, team: Team, users: [User], channels: [Channel], groups: [Group], ims: [IM]) throws {
        self.sync = SwiftDocSync(
            http: slackBot.http,
            storage: slackBot.storage
        )
        try self.sync?.updateDataset()
    }
    
    override func messageEvent(slackBot: SlackBot, webApi: WebAPI, message: MessageDecorator, previous: MessageDecorator?) throws {
        let components = message.text.components(separatedBy: " ")
        
        guard
            let sync = self.sync,
            components.count == 2,
            components.first?.hasPrefix("swift") ?? false,
            let item = components.last,
            !item.isEmpty,
            let target = message.target
            else { return }
        
        do {
            let data = try sync.lookup(item: item)
            guard let type = data as? ChatPostMessageRepresentable else { throw SwiftDocError.unableToDisplay(item: item) }
            try webApi.execute(type.makeChatPostMessage(target: target))
            
        } catch let error {
            let reply = SlackMessage(target: target).text(String(describing: error))
            try webApi.execute(reply.apiMethod())
        }
    }
}

enum SwiftDocError: Error, CustomStringConvertible {
    case itemNotFound(item: String)
    case unableToDisplay(item: String)
    
    var description: String {
        switch self {
        case .itemNotFound(let item): return "Unable to find item: \(item)"
        case .unableToDisplay(let item): return "Found \(item) but unable to convert to Slack message"
        }
    }
}

class SwiftDocSync {
    //MARK: - Properties
    private let http: HTTP
    private let storage: Storage
    private var api_urls = [String: String]()
    
    //MARK: - Lifecycle
    init(http: HTTP, storage: Storage) {
        self.http = http
        self.storage = storage
    }
    
    //MARK: - Public
    func updateDataset() throws {
        let request = HTTPRequest(method: .get, url: URL(string: "http://api.swiftdoc.org/api_urls")!)
        
        let (_, json) = try self.http.perform(with: request)
        
        var normalizedData = [String: String]()
        for (key, value) in json {
            guard let value = value as? String else { continue }
            normalizedData[key.lowercased()] = value
        }
        self.api_urls = normalizedData
    }
    func lookup(item: String) throws -> SwiftDocModelType {
        guard let url = self.api_urls[item.lowercased()] else { throw SwiftDocError.itemNotFound(item: item) }
        
        let request = HTTPRequest(method: .get, url: URL(string: url)!)
        let (_, json) = try self.http.perform(with: request)
        
        guard let type = SwiftDocModel(json: json) else { throw SwiftDocError.itemNotFound(item: item) }
        return try type.modelType.make(from: json)
    }
}

