import Models

struct Function {
    let kind: String
    let name: String
    let slug: String
    let generic: Generic?
    let params: [Parameter]
    let ret: Return?
    let `throws`: String
    let note: String
    let attr: String
    let line: String
    let comment: String
    
    let signature: String
    let uniqueSignature: String
    let declaration: String
    let uniqueSignatureURL: String
    let declarationURL: String
}

extension Function: ModelType {
    static func makeModel(with builder: ModelBuilder) throws -> Function {
        return try tryMake(builder, Function(
            kind: try builder.value(defaultable: "kind"),
            name: try builder.value(defaultable: "name"),
            slug: try builder.value(defaultable: "slug"),
            generic: try builder.optional(model: "generic"),
            params: try builder.value(model: "params"),
            ret: try builder.optional(model: "ret"),
            throws: try builder.value(defaultable: "throws"),
            note: try builder.value(defaultable: "note"),
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
