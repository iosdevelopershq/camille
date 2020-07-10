import ChameleonTestKit

extension FixtureSource {
    static func karmaMessageWithLink1() throws -> FixtureSource<Any> { try .init(jsonFile: "MessageWithLink") }
    static func karmaUnfurlLink1() throws -> FixtureSource<Any> { try.init(jsonFile: "MessageWithLinkUnfurl") }
}
