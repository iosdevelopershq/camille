import Chameleon
import XCTest

class TestService: SlackBotService {
    private let closure: () throws -> Void
    private let file: StaticString
    private let function: StaticString
    private let line: UInt


    init(file: StaticString = #file, function: StaticString = #function, line: UInt = #line, closure: @escaping () throws -> Void) {
        self.closure = closure
        self.file = file
        self.function = function
        self.line = line
    }

    func configure(slackBot: SlackBot) { }
    func connected(slackBot: SlackBot) {
        do {
            try closure()
        } catch let error {
            XCTFail("\(function): \(error)", file: file, line: line)
        }
    }
}
