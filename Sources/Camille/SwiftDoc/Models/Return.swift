import Models

struct Return {
    let line: String
    let types: [String]
}

extension Return: SwiftDocModelType {
    static func make(from json: [String : Any]) throws -> Return {
        let builder = SlackModelBuilder(json: json, models: EmptySlackModels)
        
        return Return(
            line: try builder.value(defaultable: "line"),
            types: try builder.value(defaultable: "types")
        )
    }
}
