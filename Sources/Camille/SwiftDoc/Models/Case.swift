import Models

struct Case {
    let kind: String
    let name: String
    let associated: String
    let subtypes: [String]
    let comment: String
}

extension Case: ModelType {
    static func makeModel(with builder: ModelBuilder) throws -> Case {
        return try tryMake(builder, Case(
            kind: try builder.value(defaultable: "kind"),
            name: try builder.value(defaultable: "name"),
            associated: try builder.value(defaultable: "associated"),
            subtypes: try builder.value(defaultable: "subtypes"),
            comment: try builder.value(defaultable: "comment")
        ))
    }
}
