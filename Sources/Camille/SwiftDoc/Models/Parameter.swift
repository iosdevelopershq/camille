import Models

struct Parameter {
    let name: String
    let type: String
    let note: String
    let `default`: String
    let types: [String]
}

extension Parameter: ModelType {
    static func makeModel(with builder: ModelBuilder) throws -> Parameter {
        return try tryMake(builder, Parameter(
            name: try builder.value(defaultable: "name"),
            type: try builder.value(defaultable: "type"),
            note: try builder.value(defaultable: "note"),
            default: try builder.value(defaultable: "default"),
            types: try builder.value(defaultable: "types")
        ))
    }
}
