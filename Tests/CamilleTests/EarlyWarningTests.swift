import CamilleServices
import ChameleonKit
import ChameleonTestKit
import XCTest

class EarlyWarningTests: XCTestCase {
    func testMatchingDomain() throws {
        let test = try SlackBot.test()
        let config = SlackBot.EarlyWarning.Config(alertChannel: "test", emailChannel: nil, domains: ["bad.com"])
        _ = test.bot.enableEarlyWarning(config: config)

        try test.send(.event(.teamJoin(.user())), enqueue: [
            .usersInfo(.user(email: "user@bad.com")),
            .emptyMessage()
        ])

        XCTAssertClear(test)
    }
    func testNonMatchingDomain() throws {
        let test = try SlackBot.test()
        let config = SlackBot.EarlyWarning.Config(alertChannel: "test", emailChannel: nil, domains: ["bad.com"])
        _ = test.bot.enableEarlyWarning(config: config)

        try test.send(.event(.teamJoin(.user())), enqueue: [
            .usersInfo(.user(email: "user@good.com"))
        ])

        XCTAssertClear(test)
    }
}
