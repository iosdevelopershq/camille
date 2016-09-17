import Sugar
import Models
import WebAPI

struct Type {
    let kind: String
    let name: String
    let slug: String
    let inherits: [String]
    let inherited: [String]
    let allInherited: [String]
    let generic: Generic?
    let attr: String
    let note: String
    let operators: [Operator]
    let functions: [Function]
    let types: [String]
    let properties: [Property]
    let aliases: [Typealias]
    let inits: [Init]
    let subscripts: [Subscript]
    let comment: String
    let allInherits: [String]
    let imp: [String: Any]
}

extension Type: SwiftDocModelType {
    static func make(from json: [String : Any]) throws -> Type {
        let builder = SlackModelBuilder(json: json, models: EmptySlackModels)
        
        var generic: Generic? = nil
        if let data: [String: Any] = try builder.optional(at: "generic") {
            generic = try Generic.make(from: data)
        }
        let operators: [[String: Any]] = try builder.value(defaultable: "operators")
        let functions: [[String: Any]] = try builder.value(defaultable: "functions")
        let properties: [[String: Any]] = try builder.value(defaultable: "properties")
        let aliases: [[String: Any]] = try builder.value(defaultable: "aliases")
        let inits: [[String: Any]] = try builder.value(defaultable: "inits")
        let subscripts: [[String: Any]] = try builder.value(defaultable: "subscripts")
        
        return Type(
            kind: try builder.value(defaultable: "kind"),
            name: try builder.value(defaultable: "name"),
            slug: try builder.value(defaultable: "slug"),
            inherits: try builder.value(defaultable: "inherits"),
            inherited: try builder.value(defaultable: "inherited"),
            allInherited: try builder.value(defaultable: "allInherited"),
            generic: generic,
            attr: try builder.value(defaultable: "attr"),
            note: try builder.value(defaultable: "note"),
            operators: try operators.map({ try Operator.make(from: $0) }),
            functions: try functions.map({ try Function.make(from: $0) }),
            types: try builder.value(defaultable: "types"),
            properties: try properties.map({ try Property.make(from: $0) }),
            aliases: try aliases.map({ try Typealias.make(from: $0) }),
            inits: try inits.map({ try Init.make(from: $0) }),
            subscripts: try subscripts.map({ try Subscript.make(from: $0) }),
            comment: try builder.value(defaultable: "comment"),
            allInherits: try builder.value(defaultable: "allInherits"),
            imp: try builder.value(at: "imp")
        )
    }
}

extension Type: ChatPostMessageRepresentable {
    func makeChatPostMessage(target: SlackTargetType) throws -> ChatPostMessage {
        let type = self.name.capitalized
        let fallback = "<http://swiftdoc.org/type/\(type)/|\(type)>"
        
        var json: [String: Any] = [
            "fallback": fallback,
            "text": "",
        ]
        var buttonAttachment = try MessageAttachment.makeModel(with: SlackModelBuilder.make(json: json))
        buttonAttachment.fields = try self.buttonFields()
        buttonAttachment.actions = try self.buttonActions()
        
        json["text"] = self.comment
        json["mrkdwn_in"] = ["text"]
        let commentAttachment = try MessageAttachment.makeModel(with: SlackModelBuilder.make(json: json))
        
        return ChatPostMessage(
            target: target,
            text: "Details of: *\(type)*",
            attachments: [buttonAttachment, commentAttachment]
        )
    }
    
    func buttonFields() throws -> [MessageAttachmentField] {
        var fields = [MessageAttachmentField]()
        
        fields.append(try MessageAttachmentField.makeModel(with: SlackModelBuilder.make(json: [
            "title": "Type",
            "value": self.kind,
            "short": false
            ]))
        )
        
        return fields
    }
    func buttonActions() throws -> [MessageAttachmentAction] {
        var buttons = [MessageAttachmentAction]()

        if !self.inits.isEmpty {
            let buttonJson: [String: Any] = [
                "name": "Initalisers",
                "text": "Initalisers",
                "value": "Initalisers",
                "type": "button",
                ]
            buttons.append(try MessageAttachmentAction.makeModel(with: SlackModelBuilder.make(json: buttonJson)))
        }
        if !self.functions.isEmpty {
            let buttonJson: [String: Any] = [
                "name": "Functions",
                "text": "Functions",
                "value": "Functions",
                "type": "button",
                ]
            buttons.append(try MessageAttachmentAction.makeModel(with: SlackModelBuilder.make(json: buttonJson)))
        }
        if !self.properties.isEmpty {
            let buttonJson: [String: Any] = [
                "name": "Properties",
                "text": "Properties",
                "value": "Properties",
                "type": "button",
                ]
            buttons.append(try MessageAttachmentAction.makeModel(with: SlackModelBuilder.make(json: buttonJson)))
        }
        if !self.subscripts.isEmpty {
            let buttonJson: [String: Any] = [
                "name": "Subscripts",
                "text": "Subscripts",
                "value": "Subscripts",
                "type": "button",
                ]
            buttons.append(try MessageAttachmentAction.makeModel(with: SlackModelBuilder.make(json: buttonJson)))
        }
        
        if !self.allInherits.isEmpty {
            let buttonJson: [String: Any] = [
                "name": "Inherits",
                "text": "Inherits",
                "value": "Inherits",
                "type": "button",
                ]
            buttons.append(try MessageAttachmentAction.makeModel(with: SlackModelBuilder.make(json: buttonJson)))
        }
        if !self.allInherited.isEmpty {
            let buttonJson: [String: Any] = [
                "name": "Inherited",
                "text": "Inherited",
                "value": "Inherited",
                "type": "button",
                ]
            buttons.append(try MessageAttachmentAction.makeModel(with: SlackModelBuilder.make(json: buttonJson)))
        }

        return buttons
    }
}

extension SlackMessage {
    func forEach<S: Sequence>(seq: S, function: (SlackMessage, S.Iterator.Element) -> SlackMessage) -> SlackMessage {
        return seq.reduce(self) { message, element in
            return function(message, element)
        }
    }
}

