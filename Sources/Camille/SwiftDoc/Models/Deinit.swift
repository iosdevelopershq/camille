import Models

struct Deinit {
    let kind: String
    let comment: String
}

extension Deinit: ModelType {
    static func makeModel(with builder: ModelBuilder) throws -> Deinit {
        return try tryMake(builder, Deinit(
            kind: try builder.value(defaultable: "kind"),
            comment: try builder.value(defaultable: "comment")
        ))
    }
}
