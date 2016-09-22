import Models

struct Generic {
    let line: String
    let formatted: String
    let types: [String]
}

extension Generic: ModelType {
    static func makeModel(with builder: ModelBuilder) throws -> Generic {
        return try tryMake(builder, Generic(
            line: try builder.value(defaultable: "line"),
            formatted: try builder.value(defaultable: "formatted"),
            types: try builder.value(defaultable: "types")
        ))
    }
}
