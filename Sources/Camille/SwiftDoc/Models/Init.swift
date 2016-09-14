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

extension Init: SwiftDocModelType {
    static func make(from json: [String : Any]) throws -> Init {
        let builder = SlackModelBuilder(json: json, models: EmptySlackModels)
        
        var generic: Generic? = nil
        if let data: [String: Any] = try builder.optional(at: "generic") {
            generic = try Generic.make(from: data)
        }
        let params: [[String: Any]] = try builder.value(defaultable: "params")
        
        return Init(
            kind: try builder.value(defaultable: "kind"),
            generic: generic,
            params: try params.map({ try Parameter.make(from: $0) }),
            init: try builder.value(defaultable: "init"),
            note: try builder.value(defaultable: "note"),
            comment: try builder.value(defaultable: "comment"),
            signature: try builder.value(defaultable: "signature"),
            uniqueSignature: try builder.value(defaultable: "uniqueSignature"),
            declaration: try builder.value(defaultable: "declaration"),
            uniqueSignatureURL: try builder.value(defaultable: "uniqueSignatureURL"),
            declarationURL: try builder.value(defaultable: "declarationURL")
        )
    }
}
