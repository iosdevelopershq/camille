import Sugar
import Models
import WebAPI

struct Type {
    let kind: String
    let name: String
    let slug: String
    let inherits: [String]
    let inherited: [String]
    let allInherited: [String]
    let generic: Generic?
    let attr: String
    let note: String
    let operators: [Operator]
    let functions: [Function]
    let types: [String]
    let properties: [Property]
    let aliases: [Typealias]
    let inits: [Init]
    let subscripts: [Subscript]
    let comment: String
    let allInherits: [String]
    let imp: [String: Any]
}

extension Type: SwiftDocModelType {
    static func make(from json: [String : Any]) throws -> Type {
        let builder = SlackModelBuilder(json: json, models: EmptySlackModels)
        
        var generic: Generic? = nil
        if let data: [String: Any] = try builder.optional(at: "generic") {
            generic = try Generic.make(from: data)
        }
        let operators: [[String: Any]] = try builder.value(defaultable: "operators")
        let functions: [[String: Any]] = try builder.value(defaultable: "functions")
        let properties: [[String: Any]] = try builder.value(defaultable: "properties")
        let aliases: [[String: Any]] = try builder.value(defaultable: "aliases")
        let inits: [[String: Any]] = try builder.value(defaultable: "inits")
        let subscripts: [[String: Any]] = try builder.value(defaultable: "subscripts")
        
        return Type(
            kind: try builder.value(defaultable: "kind"),
            name: try builder.value(defaultable: "name"),
            slug: try builder.value(defaultable: "slug"),
            inherits: try builder.value(defaultable: "inherits"),
            inherited: try builder.value(defaultable: "inherited"),
            allInherited: try builder.value(defaultable: "allInherited"),
            generic: generic,
            attr: try builder.value(defaultable: "attr"),
            note: try builder.value(defaultable: "note"),
            operators: try operators.map({ try Operator.make(from: $0) }),
            functions: try functions.map({ try Function.make(from: $0) }),
            types: try builder.value(defaultable: "types"),
            properties: try properties.map({ try Property.make(from: $0) }),
            aliases: try aliases.map({ try Typealias.make(from: $0) }),
            inits: try inits.map({ try Init.make(from: $0) }),
            subscripts: try subscripts.map({ try Subscript.make(from: $0) }),
            comment: try builder.value(defaultable: "comment"),
            allInherits: try builder.value(defaultable: "allInherits"),
            imp: try builder.value(at: "imp")
        )
    }
}

extension Type: ChatPostMessageRepresentable {
    func makeChatPostMessage(target: SlackTargetType) -> ChatPostMessage {
        let result = SlackMessage(target: target, options: [.parse(.none)])
            .text("\(self.name) (\(self.kind))", formatting: .Code)
            .newLine()
            .text("Properties:", formatting: .Bold)
            .newLine()
            .forEach(seq: self.properties.prefix(2)) { message, property in
                return message
                    .text(property.name)
                    .newLine()
            }
            //.text(self.comment)
        
        return result.apiMethod()
    }
}

extension SlackMessage {
    func forEach<S: Sequence>(seq: S, function: (SlackMessage, S.Iterator.Element) -> SlackMessage) -> SlackMessage {
        seq.forEach { _ = function(self, $0) }
        return self
    }
}

