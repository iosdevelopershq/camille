import Models

struct Subscript {
    let kind: String
    let params: [Parameter]
    let ret: Return?
    let line: String
    let comment: String
    
    let signature: String
    let uniqueSignature: String
    let declaration: String
    let uniqueSignatureURL: String
    let declarationURL: String
}

extension Subscript: ModelType {
    static func makeModel(with builder: ModelBuilder) throws -> Subscript {
        return try tryMake(builder, Subscript(
            kind: try builder.value(defaultable: "kind"),
            params: try builder.value(model: "params"),
            ret: try builder.optional(model: "ret"),
            line: try builder.value(defaultable: "line"),
            comment: try builder.value(defaultable: "comment"),
            signature: try builder.value(defaultable: "signature"),
            uniqueSignature: try builder.value(defaultable: "uniqueSignature"),
            declaration: try builder.value(defaultable: "declaration"),
            uniqueSignatureURL: try builder.value(defaultable: "uniqueSignatureURL"),
            declarationURL: try builder.value(defaultable: "declarationURL")
        ))
    }
}
