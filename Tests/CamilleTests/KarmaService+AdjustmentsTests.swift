import XCTest
import Models
@testable import CamilleServices

class KarmaService_AdjustmentsTests: XCTestCase {
    static var allTests = [
        ("testKarmaAdjustments", testKarmaAdjustments),
    ]

    func testKarmaAdjustments() throws {
        try execute(
            load: { [KarmaService(storage: $0.storage)] },
            test: { env in
                let adjustments: [(sender: String, text: String, change: Int)] = [
                    (ModelIDs.mockUser2, "<@\(ModelIDs.mockUser1)> hello", 0),
                    (ModelIDs.mockUser2, "@\(ModelIDs.mockUser1) ++", 0),
                    (ModelIDs.mockUser2, "@\(ModelIDs.mockUser1)++", 0),
                    (ModelIDs.mockUser1, "<@\(ModelIDs.mockUser1)>++", 0),
                    (ModelIDs.mockUser1, "<@\(ModelIDs.mockUser1)> ++", 0),

                    (ModelIDs.mockUser2, "<@\(ModelIDs.mockUser1)>++", 1),
                    (ModelIDs.mockUser2, "<@\(ModelIDs.mockUser1)> ++", 1),
                    (ModelIDs.mockUser2, "<@\(ModelIDs.mockUser1)>++\n", 1),
                    (ModelIDs.mockUser2, "\n<@\(ModelIDs.mockUser1)>++", 1),

                    (ModelIDs.mockUser2, "<@\(ModelIDs.mockUser1)>++ <@\(ModelIDs.mockUser1)>++", 2),
                    (ModelIDs.mockUser2, "<@\(ModelIDs.mockUser1)>++\n<@\(ModelIDs.mockUser1)>++", 2),
                    (ModelIDs.mockUser2, "\n<@\(ModelIDs.mockUser1)>++\n\n<@\(ModelIDs.mockUser1)>++\n", 2),
                    ]

                for (sender, text, change) in adjustments {
                    env.storage.removeAll()

                    let message = Message.from(sender, in: ModelIDs.channel1, saying: text)
                    try env.socket.send(packet: message)

                    let value: Int = try env.storage.get(key: ModelIDs.mockUser1, from: KarmaService.Keys.namespace, or: 0)
                    XCTAssertEqual(change, value)
                }
            }
        )
    }
}
