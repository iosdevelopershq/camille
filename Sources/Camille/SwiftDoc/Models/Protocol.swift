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

extension Protocol: ModelType {
    static func makeModel(with builder: ModelBuilder) throws -> Protocol {
        return try tryMake(builder, Protocol(
            kind: try builder.value(defaultable: "kind"),
            name: try builder.value(defaultable: "name"),
            slug: try builder.value(defaultable: "slug"),
            inherits: try builder.value(defaultable: "inherits"),
            inherited: try builder.value(defaultable: "inherited"),
            allInherited: try builder.value(defaultable: "allInherited"),
            attr: try builder.value(defaultable: "attr"),
            operators: try builder.value(defaultable: "operators"),
            functions: try builder.value(defaultable: "functions"),
            types: try builder.value(defaultable: "types"),
            properties: try builder.value(defaultable: "properties"),
            aliases: try builder.value(defaultable: "aliases"),
            inits: try builder.value(defaultable: "inits"),
            subscripts: try builder.value(defaultable: "subscripts"),
            imp: try builder.optional(at: "imp"),
            comment: try builder.value(defaultable: "comment"),
            requiresSelf: try builder.value(defaultable: "requiresSelf")
        ))
    }
}
