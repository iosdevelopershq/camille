import Models

struct Property {
    let kind: String
    let note: String
    let final: String
    let name: String
    let type: String
    let readonly: Bool
    let stat: String
    let subtypes: [String]
    let comment: String
    
    let signature: String
    let uniqueSignature: String
    let declaration: String
    let uniqueSignatureURL: String
    let declarationURL: String
}

extension Property: ModelType {
    static func makeModel(with builder: ModelBuilder) throws -> Property {
        return try tryMake(builder, Property(
            kind: try builder.value(defaultable: "kind"),
            note: try builder.value(defaultable: "note"),
            final: try builder.value(defaultable: "final"),
            name: try builder.value(defaultable: "name"),
            type: try builder.value(defaultable: "type"),
            readonly: try builder.value(defaultable: "readonly"),
            stat: try builder.value(defaultable: "stat"),
            subtypes: try builder.value(defaultable: "subtypes"),
            comment: try builder.value(defaultable: "comment"),
            signature: try builder.value(defaultable: "signature"),
            uniqueSignature: try builder.value(defaultable: "uniqueSignature"),
            declaration: try builder.value(defaultable: "declaration"),
            uniqueSignatureURL: try builder.value(defaultable: "uniqueSignatureURL"),
            declarationURL: try builder.value(defaultable: "declarationURL")
        ))
    }
}
