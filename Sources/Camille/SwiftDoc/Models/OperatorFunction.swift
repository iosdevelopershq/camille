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

extension OperatorFunction: SwiftDocModelType {
    static func make(from json: [String : Any]) throws -> OperatorFunction {
        let builder = SlackModelBuilder(json: json, models: EmptySlackModels)
        
        var generic: Generic? = nil
        if let json: [String: Any] = try builder.optional(at: "generic") {
            generic = try Generic.make(from: json)
        }
        
        let params: [[String: Any]] = try builder.value(defaultable: "params")
        
        var ret: Return? = nil
        if let json: [String: Any] = try builder.optional(at: "ret") {
            ret = try Return.make(from: json)
        }
        
        return OperatorFunction(
            kind: try builder.value(defaultable: "kind"),
            name: try builder.value(defaultable: "name"),
            slug: try builder.value(defaultable: "slug"),
            generic: generic,
            place: try builder.value(defaultable: "place"),
            params: try params.map({ try Parameter.make(from: $0) }),
            ret: ret,
            attr: try builder.value(defaultable: "attr"),
            line: try builder.value(defaultable: "line"),
            comment: try builder.value(defaultable: "comment"),
            signature: try builder.value(defaultable: "signature"),
            uniqueSignature: try builder.value(defaultable: "uniqueSignature"),
            declaration: try builder.value(defaultable: "declaration"),
            uniqueSignatureURL: try builder.value(defaultable: "uniqueSignatureURL"),
            declarationURL: try builder.value(defaultable: "declarationURL")
        )
    }
}
