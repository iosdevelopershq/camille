import Models

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

extension Type: ModelType {
    static func makeModel(with builder: ModelBuilder) throws -> Type {
        return try tryMake(builder, Type(
            kind: try builder.value(defaultable: "kind"),
            name: try builder.value(defaultable: "name"),
            slug: try builder.value(defaultable: "slug"),
            inherits: try builder.value(defaultable: "inherits"),
            inherited: try builder.value(defaultable: "inherited"),
            allInherited: try builder.value(defaultable: "allInherited"),
            generic: try builder.optional(model: "generic"),
            attr: try builder.value(defaultable: "attr"),
            note: try builder.value(defaultable: "note"),
            operators: try builder.value(defaultable: "operators"),
            functions: try builder.value(defaultable: "functions"),
            types: try builder.value(defaultable: "types"),
            properties: try builder.value(defaultable: "properties"),
            aliases: try builder.value(defaultable: "aliases"),
            inits: try builder.value(defaultable: "inits"),
            subscripts: try builder.value(defaultable: "subscripts"),
            comment: try builder.value(defaultable: "comment"),
            allInherits: try builder.value(defaultable: "allInherits"),
            imp: try builder.value(at: "imp")
        ))
    }
}
