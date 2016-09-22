import Models
import WebAPI

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
