import Models

struct Generic {
    let line: String
    let formatted: String
    let types: [String]
}

extension Generic: SwiftDocModelType {
    static func make(from json: [String : Any]) throws -> Generic {
        let builder = SlackModelBuilder(json: json, models: EmptySlackModels)
        
        return Generic(
            line: try builder.value(defaultable: "line"),
            formatted: try builder.value(defaultable: "formatted"),
            types: try builder.value(defaultable: "types")
        )
    }
}
