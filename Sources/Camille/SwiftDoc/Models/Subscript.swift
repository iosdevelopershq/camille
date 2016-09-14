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

extension Subscript: SwiftDocModelType {
    static func make(from json: [String : Any]) throws -> Subscript {
        let builder = SlackModelBuilder(json: json, models: EmptySlackModels)
        
        let params: [[String: Any]] = try builder.value(defaultable: "params")
        var ret: Return? = nil
        if let data: [String: Any] = try builder.optional(at: "ret") {
            ret = try Return.make(from: data)
        }
        
        return Subscript(
            kind: try builder.value(defaultable: "kind"),
            params: try params.map({ try Parameter.make(from: $0) }),
            ret: ret,
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
