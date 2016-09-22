import Models

struct Typealias {
    let kind: String
    let name: String
    let type: String
    let proto: String
    let comment: String
}

extension Typealias: ModelType {
    static func makeModel(with builder: ModelBuilder) throws -> Typealias {
        return try tryMake(builder, Typealias(
            kind: try builder.value(defaultable: "kind"),
            name: try builder.value(defaultable: "name"),
            type: try builder.value(defaultable: "type"),
            proto: try builder.value(defaultable: "proto"),
            comment: try builder.value(defaultable: "comment")
        ))
    }
}
