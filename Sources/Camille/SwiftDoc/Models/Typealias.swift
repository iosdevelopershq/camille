import Models

struct Typealias {
    let kind: String
    let name: String
    let type: String
    let proto: String
    let comment: String
}

extension Typealias: SwiftDocModelType {
    static func make(from json: [String : Any]) throws -> Typealias {
        let builder = SlackModelBuilder(json: json, models: EmptySlackModels)
        
        return Typealias(
            kind: try builder.value(defaultable: "kind"),
            name: try builder.value(defaultable: "name"),
            type: try builder.value(defaultable: "type"),
            proto: try builder.value(defaultable: "proto"),
            comment: try builder.value(defaultable: "comment")
        )
    }
}
