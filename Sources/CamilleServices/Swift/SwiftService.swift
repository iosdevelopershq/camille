//import Foundation
//import Chameleon
//
//struct CodeMatcher: Matcher {
//    func match(against input: String) -> Match? {
//        guard input.hasPrefix("`") && input.hasSuffix("`") else { return nil }
//
//        let code = input.trim(characters: ["`"]).stringByDecodingHTMLEntities
//
//        guard !code.isEmpty else { return nil }
//
//        return Match(key: nil, value: code, matched: input)
//    }
//    var matcherDescription: String {
//        return "(code)"
//    }
//}
//
//public class SwiftService: SlackBotMessageService, HelpRepresentable {
//    private let network: Network
//    private let token: String
//
//    public let topic = "Swift Code"
//    public let description = "Execute some Swift code and see the result"
//    public let pattern: [Matcher] = [["execute", "run"].any, "\n".orNone, CodeMatcher().using(key: Keys.code)]
//
//    enum Keys {
//        static let code = "code"
//    }
//
//    public init(network: Network, token: String) {
//        self.network = network
//        self.token = token
//    }
//
//    public func configure(slackBot: SlackBot) {
//        slackBot.registerHelp(item: self)
//
//        configureMessageService(slackBot: slackBot)
//    }
//    public func onMessage(slackBot: SlackBot, message: MessageDecorator, previous: MessageDecorator?) throws {
//        try slackBot.route(message, matching: self) { bot, msg, match in
//            let result = try request(code: match.value(key: Keys.code))
//
//            let response = try msg.respond()
//            response.text(["Output:"]).newLine()
//
//            if !result.stderr.isEmpty {
//                response.text([result.stderr.pre])
//
//            } else {
//                response.text([result.stdout.quote])
//            }
//
//            try bot.send(response.makeChatMessage())
//        }
//    }
//
//    private func request(code: String) throws -> GlotResponse {
//        let body: [String: Any] = [
//            "files": [
//                [
//                    "name": "main.swift",
//                    "content": code,
//                ]
//            ]
//        ]
//
//        let request = NetworkRequest(
//            method: .POST,
//            url: "https://run.glot.io/languages/swift/latest",
//            headers: [
//                "Authorization": "Token \(token)",
//                "Content-type": "application/json",
//            ],
//            body: body.makeData()
//        )
//
//        let response = try network.perform(request: request)
//
//        guard let json = response.jsonDictionary
//            else { throw NetworkError.invalidResponse(response) }
//
//        let decoder = Decoder(data: json)
//        return try GlotResponse(decoder: decoder)
//    }
//}
//
//private struct GlotResponse {
//    let stdout: String
//    let stderr: String
//    let error: String
//}
//
//extension GlotResponse: Common.Decodable {
//    init(decoder: Common.Decoder) throws {
//        self = try decode {
//            return GlotResponse(
//                stdout: try decoder.value(at: ["stdout"]),
//                stderr: try decoder.value(at: ["stderr"]),
//                error: try decoder.value(at: ["error"])
//            )
//        }
//    }
//}
