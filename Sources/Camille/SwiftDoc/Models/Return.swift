import Models

struct Return {
    let line: String
    let types: [String]
}

extension Return: ModelType {
    static func makeModel(with builder: ModelBuilder) throws -> Return {
        return try tryMake(builder, Return(
            line: try builder.value(defaultable: "line"),
            types: try builder.value(defaultable: "types")
        ))
    }
}
