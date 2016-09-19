import Models

struct Operator {
    let kind: String
    let place: String
    let name: String
    let slug: String
    let assignment: Bool
    let associativity: String
    let precedence: String
    let comment: String
    let functions: [OperatorFunction]
}

extension Operator: SwiftDocModelType {
    static func make(from json: [String : Any]) throws -> Operator {
        let builder = SlackModelBuilder.make(json: json)
        
        let functions: [[String: Any]] = try builder.value(defaultable: "functions")
        
        return Operator(
            kind: try builder.value(defaultable: "kind"),
            place: try builder.value(defaultable: "place"),
            name: try builder.value(defaultable: "name"),
            slug: try builder.value(defaultable: "slug"),
            assignment: try builder.value(defaultable: "assignment"),
            associativity: try builder.value(defaultable: "associativity"),
            precedence: try builder.value(defaultable: "precedence"),
            comment: try builder.value(defaultable: "comment"),
            functions: try functions.map({ try OperatorFunction.make(from: $0) })
        )
    }
}
