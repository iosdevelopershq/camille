import Models

struct Init {
    let kind: String
    let generic: Generic?
    let params: [Parameter]
    let `init`: String
    let note: String
    let comment: String
    
    let signature: String
    let uniqueSignature: String
    let declaration: String
    let uniqueSignatureURL: String
    let declarationURL: String
}

extension Init: ModelType {
    static func makeModel(with builder: ModelBuilder) throws -> Init {
        return try tryMake(builder, Init(
            kind: try builder.value(defaultable: "kind"),
            generic: try builder.optional(model: "generic"),
            params: try builder.value(model: "params"),
            init: try builder.value(defaultable: "init"),
            note: try builder.value(defaultable: "note"),
            comment: try builder.value(defaultable: "comment"),
            signature: try builder.value(defaultable: "signature"),
            uniqueSignature: try builder.value(defaultable: "uniqueSignature"),
            declaration: try builder.value(defaultable: "declaration"),
            uniqueSignatureURL: try builder.value(defaultable: "uniqueSignatureURL"),
            declarationURL: try builder.value(defaultable: "declarationURL")
        ))
    }
}
