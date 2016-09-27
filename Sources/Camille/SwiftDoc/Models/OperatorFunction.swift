import Models

struct OperatorFunction {
    let kind: String
    let name: String
    let slug: String
    let generic: Generic?
    let place: String
    let params: [Parameter]
    let ret: Return?
    let attr: String
    let line: String
    let comment: String
    
    let signature: String
    let uniqueSignature: String
    let declaration: String
    let uniqueSignatureURL: String
    let declarationURL: String
}

extension OperatorFunction: ModelType {
    static func makeModel(with builder: ModelBuilder) throws -> OperatorFunction {
        return try tryMake(builder, OperatorFunction(
            kind: try builder.value(defaultable: "kind"),
            name: try builder.value(defaultable: "name"),
            slug: try builder.value(defaultable: "slug"),
            generic: try builder.optional(model: "generic"),
            place: try builder.value(defaultable: "place"),
            params: try builder.value(models: "params"),
            ret: try builder.optional(model: "ret"),
            attr: try builder.value(defaultable: "attr"),
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
