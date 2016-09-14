import Models

struct Case {
    let kind: String
    let name: String
    let associated: String
    let subtypes: [String]
    let comment: String
}

extension Case: SwiftDocModelType {
    static func make(from json: [String : Any]) throws -> Case {
        let builder = SlackModelBuilder(json: json, models: EmptySlackModels)
        
        return Case(
            kind: try builder.value(defaultable: "kind"),
            name: try builder.value(defaultable: "name"),
            associated: try builder.value(defaultable: "associated"),
            subtypes: try builder.value(defaultable: "subtypes"),
            comment: try builder.value(defaultable: "comment")
        )
    }
}
