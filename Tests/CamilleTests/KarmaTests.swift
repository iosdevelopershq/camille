import ChameleonKit
import ChameleonTestKit
@testable import CamilleServices
import XCTest

class KarmaTests: XCTestCase {
    func testKarma_NoMatches() throws {
        let test = try SlackBot.test()
        let storage = MemoryStorage()
        _ = test.bot.enableKarma(config: .default(), storage: storage)

        try test.send(.event(.message("hello")))
        try test.send(.event(.message([.user("1"), .text("hey!!")])))

        try XCTAssertEqual(storage.keys(in: SlackBot.Karma.Keys.namespace), [])
        XCTAssertClear(test)
    }

    func testKarma_NormalMatches_WhitespaceVariants() throws {
        let test = try SlackBot.test()
        let storage = MemoryStorage()
        _ = test.bot.enableKarma(config: .default(), storage: storage)

        try test.send(.event(.message([.user("1"), .text(" ++")])), enqueue: [.emptyMessage()])
        try test.send(.event(.message([.user("1"), .text("++")])), enqueue: [.emptyMessage()])
        try test.send(.event(.message([.user("1"), .text("++ ")])), enqueue: [.emptyMessage()])
        try test.send(.event(.message([.user("1"), .text(" ++ ")])), enqueue: [.emptyMessage()])

        try XCTAssertEqual(storage.keys(in: SlackBot.Karma.Keys.namespace), ["1"])
        try XCTAssertEqual(storage.get(forKey: "1", from: SlackBot.Karma.Keys.namespace), 4)
        XCTAssertClear(test)
    }

    func testKarma_MultipleMatches() throws {
        let test = try SlackBot.test()
        let storage = MemoryStorage()
        _ = test.bot.enableKarma(config: .default(), storage: storage)

        try test.send(
            .event(.message([
                .text("thanks "), .user("1"), .text(" ++ and also "), .user("2"), .text("++")
            ])),
            enqueue: [.emptyMessage()]
        )

        try XCTAssertEqual(storage.keys(in: SlackBot.Karma.Keys.namespace).sorted(), ["1", "2"])
        try XCTAssertEqual(storage.get(forKey: "1", from: SlackBot.Karma.Keys.namespace), 1)
        try XCTAssertEqual(storage.get(forKey: "2", from: SlackBot.Karma.Keys.namespace), 1)
        XCTAssertClear(test)
    }

    func testKarma_MultipleMatches_Consolidation() throws {
        let test = try SlackBot.test()
        let storage = MemoryStorage()
        _ = test.bot.enableKarma(config: .default(), storage: storage)

        try test.send(
            .event(.message([
                .text("thanks "), .user("1"), .text(" ++ and also "), .user("2"), .text("++ "), .user("1"), .text(" ++ "), .user("2"), .text(" --, sorry!")
            ])),
            enqueue: [.emptyMessage()]
        )

        try XCTAssertEqual(storage.keys(in: SlackBot.Karma.Keys.namespace), ["1"])
        try XCTAssertEqual(storage.get(forKey: "1", from: SlackBot.Karma.Keys.namespace), 2)
        XCTAssertClear(test)
    }

    func testKarma_EdgeCase_Unfurl() throws {
        let test = try SlackBot.test()
        let storage = MemoryStorage()
        _ = test.bot.enableKarma(config: .default(), storage: storage)

        try test.send(.event(.karmaMessageWithLink1()), enqueue: [.emptyMessage()])
        try test.send(.event(.karmaUnfurlLink1()))

        try XCTAssertEqual(storage.keys(in: SlackBot.Karma.Keys.namespace), ["U0000000002"])
        try XCTAssertEqual(storage.get(forKey: "U0000000002", from: SlackBot.Karma.Keys.namespace), 1)
        XCTAssertClear(test)
    }

    func testKarma_EdgeCase_FalsePositives() throws {
        let test = try SlackBot.test()
        let storage = MemoryStorage()
        _ = test.bot.enableKarma(config: .default(), storage: storage)

        try test.send(
            .event(.message([
                .text("Hey "), .user("1"), .text(" have you used C++?")
            ]))
        )

        try XCTAssertEqual(storage.keys(in: SlackBot.Karma.Keys.namespace), [])
        XCTAssertClear(test)
    }

    func testKarma_EdgeCase_SelfKarma() throws {
        let test = try SlackBot.test()
        let storage = MemoryStorage()
        _ = test.bot.enableKarma(config: .default(), storage: storage)

        try test.send(.event(.message(userId: "1", [.user("1"), .text(" ++")])))

        try XCTAssertEqual(storage.keys(in: SlackBot.Karma.Keys.namespace), [])
        XCTAssertClear(test)
    }

    func testKarma_EdgeCase_Punctuation() throws {
        let test = try SlackBot.test()
        let storage = MemoryStorage()
        _ = test.bot.enableKarma(config: .default(), storage: storage)

        try test.send(.event(.message([.text("(btw, "), .user("1"), .text("++)")])), enqueue: [.emptyMessage()])

        try XCTAssertEqual(storage.keys(in: SlackBot.Karma.Keys.namespace), ["1"])
        try XCTAssertEqual(storage.get(forKey: "1", from: SlackBot.Karma.Keys.namespace), 1)
        XCTAssertClear(test)
    }
}
