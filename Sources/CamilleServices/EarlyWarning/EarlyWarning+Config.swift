import Foundation
import ChameleonKit

extension SlackBot.EarlyWarning {
    public struct Config {
        /// Channel to report new users whose email domain that match one of the provided domains
        /// Provide `nil` to not report on this
        public var alertChannel: Identifier<Channel>?

        /// Channel to report new users whose email domain _doesn't_ match one of the provided domains
        /// Provide `nil` to not report on this
        public var emailChannel: Identifier<Channel>?

        /// Domains to check new users emails against
        public var domains: Set<String>

        public init(alertChannel: String?, emailChannel: String?, domains: Set<String>) {
            self.alertChannel = alertChannel.map(Identifier.init(rawValue:))
            self.emailChannel = emailChannel.map(Identifier.init(rawValue:))
            self.domains = domains
        }

        public static func `default`() throws -> Config {
            let blocklistUrl = URL(string: "https://raw.githubusercontent.com/martenson/disposable-email-domains/master/disposable_email_blocklist.conf")!
            let blocklist = try Array(import: blocklistUrl, delimiters: .newlines)

            let domains = [
                "apkmd.com",
                "autism.exposed",
                "car101.pro",
                "deaglenation.tv",
                "gamergate.us",
                "housat.com",
                "muslims.exposed",
                "nutpa.net",
                "p33.org",
                "vps30.com",
                "awdrt.com",
                "ttirv.com",
            ]

            return .init(alertChannel: "admins", emailChannel: "new-users", domains: Set(blocklist + domains))
        }
    }
}

private extension Array where Element == String {
    init(import: URL, delimiters: CharacterSet) throws {
        let data = try Data(contentsOf: `import`)
        if  let string = String(data: data, encoding: .utf8) {
            self = string.components(separatedBy: delimiters)

        } else {
            self = []
        }
    }
}
