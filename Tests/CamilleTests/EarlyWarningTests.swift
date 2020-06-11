import CamilleServices
import ChameleonKit
import ChameleonTestKit
import XCTest

class EarlyWarningTests: XCTestCase {
    func testMatchingDomain() throws {
        let test = try SlackBot.test()
        let config = SlackBot.EarlyWarning.Config(channel: "test", domains: ["bad.com"])
        _ = test.bot.enableEmailFilter(config: config)

        try test.send(.event(.teamJoin(email: "user@bad.com")), enqueue: .emptyMessage())

        XCTAssertClear(test)
    }
    func testNonMatchingDomain() throws {
        let test = try SlackBot.test()
        let config = SlackBot.EarlyWarning.Config(channel: "test", domains: ["bad.com"])
        _ = test.bot.enableEmailFilter(config: config)

        try test.send(.event(.teamJoin(email: "user@good.com")))

        XCTAssertClear(test)
    }
}

extension FixtureSource {
    static func teamJoin(email: String) -> FixtureSource<SlackReceiver> {
        return .init(raw: """
        {
            "type": "team_join",
            "user": {
                "id": "U00000000",
                "team_id": "T00000000",
                "name": "username",
                "deleted": false,
                "color": "d58247",
                "real_name": "Real Name",
                "tz": "America/Los_Angeles",
                "tz_label": "Pacific Daylight Time",
                "tz_offset": -25200,
                "profile": {
                    "title": "User",
                    "phone": "",
                    "skype": "",
                    "real_name": "Real Name",
                    "real_name_normalized": "Real Name",
                    "display_name": "username",
                    "display_name_normalized": "username",
                    "fields": null,
                    "status_text": ":walking_zombie:",
                    "status_emoji": ":smile:",
                    "status_expiration": 0,
                    "avatar_hash": "63b708f074ef",
                    "image_original": "https://avatars.slack-edge.com/2016-08-31/75135379_68f074ef45bf5063_original.jpg",
                    "is_custom_image": true,
                    "email": "\(email)",
                    "first_name": "Real",
                    "last_name": "Name",
                    "image_24": "https://avatars.slack-edge.com/2016-08-31/751035379_63b774ef4f5063_24.jpg",
                    "image_32": "https://avatars.slack-edge.com/2016-08-31/751035379_63b774ef4f5063_32.jpg",
                    "image_48": "https://avatars.slack-edge.com/2016-08-31/751035379_63b774ef4f5063_48.jpg",
                    "image_72": "https://avatars.slack-edge.com/2016-08-31/751035379_63b774ef4f5063_72.jpg",
                    "image_192": "https://avatars.slack-edge.com/2016-08-31/751635379_63b074efbf5063_192.jpg",
                    "image_512": "https://avatars.slack-edge.com/2016-08-31/751635379_63b074efbf5063_512.jpg",
                    "image_1024": "https://avatars.slack-edge.com/2016-08-31/754635379_63f074e5bf5063_512.jpg",
                    "status_text_canonical": "",
                    "team": "T00000000"
                },
                "is_admin": false,
                "is_owner": false,
                "is_primary_owner": false,
                "is_restricted": false,
                "is_ultra_restricted": false,
                "is_bot": false,
                "is_app_user": false,
                "updated": 1569981133,
                "locale": "en-US"
            }
        }
        """)
    }
}
