import Models

struct Protocol {
    let kind: String
    let name: String
    let slug: String
    let inherits: [String]
    let inherited: [String]
    let allInherited: [String]
    let attr: String
    let operators: [Operator]
    let functions:  [Function]
    let types: [String]
    let properties: [Property]
    let aliases: [Typealias]
    let inits: [Init]
    let subscripts: [Subscript]
    let imp: [String: Any]?
    let comment: String
    let requiresSelf: Bool
}

extension Protocol: SwiftDocModelType {
    static func make(from json: [String : Any]) throws -> Protocol {
        let builder = SlackModelBuilder.make(json: json)
        
        let operators: [[String: Any]] = try builder.value(defaultable: "operators")
        let functions: [[String: Any]] = try builder.value(defaultable: "functions")
        let properties: [[String: Any]] = try builder.value(defaultable: "properties")
        let aliases: [[String: Any]] = try builder.value(defaultable: "aliases")
        let inits: [[String: Any]] = try builder.value(defaultable: "inits")
        let subscripts: [[String: Any]] = try builder.value(defaultable: "subscripts")
        
        return Protocol(
            kind: try builder.value(defaultable: "kind"),
            name: try builder.value(defaultable: "name"),
            slug: try builder.value(defaultable: "slug"),
            inherits: try builder.value(defaultable: "inherits"),
            inherited: try builder.value(defaultable: "inherited"),
            allInherited: try builder.value(defaultable: "allInherited"),
            attr: try builder.value(defaultable: "attr"),
            operators: try operators.map({ try Operator.make(from: $0) }),
            functions: try functions.map({ try Function.make(from: $0) }),
            types: try builder.value(defaultable: "types"),
            properties: try properties.map({ try Property.make(from: $0) }),
            aliases: try aliases.map({ try Typealias.make(from: $0) }),
            inits: try inits.map({ try Init.make(from: $0) }),
            subscripts: try subscripts.map({ try Subscript.make(from: $0) }),
            imp: try builder.optional(at: "imp"),
            comment: try builder.value(defaultable: "comment"),
            requiresSelf: try builder.value(defaultable: "requiresSelf")
        )
    }
}
