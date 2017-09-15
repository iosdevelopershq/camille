import Foundation

enum WebAPIResponse {
    static let rtm_connect: [String: Any] = [
        "ok": true,
        "url": "wss://ms9.slack-msgs.com/websocket/2I5yBpcvk",
        "team": [
            "id": "T654321",
            "name": "Librarian Society of Soledad",
            "domain": "libsocos",
            "enterprise_id": "E234567",
            "enterprise_name": "Intercontinental Librarian Society"
        ],
        "self": [
            "id": "B123456",
            "name": "Bot"
        ]
    ]

    static func channels_info(id: String, name: String, creator: String = ModelIDs.mockUser1) -> [String: Any] {
        return [
            "ok": true,
            "channel": [
                "id": id,
                "name": name,
                "created": Int(Date().timeIntervalSince1970),
                "creator": creator,
                "members": [],
            ]
        ]
    }

    static func users_info(id: String) -> [String: Any] {
        return [
            "ok": true,
            "user": [
                "id": id,
                "color": "9f69e7",
                "profile": [
                    "status_text": "Print is dead",
                    "real_name": "Egon Spengler",
                    "display_name": "spengler",
                    "email": "spengler@ghostbusters.example.com",
                    "image_512": "https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg",
                ],
                "is_admin": false,
                "is_owner": false,
                "is_bot": false,
                "updated": 1502138686,
            ]
        ]
    }
}

enum ModelIDs {
    static let mockUser1 = "U_User1"
    static let mockUser2 = "U_User2"

    static let channel1 = "C_Channel1"
}

