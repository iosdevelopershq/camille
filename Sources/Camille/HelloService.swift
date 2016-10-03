import Bot
import Sugar
import Foundation

final class HelloService: SlackMessageService {
    override func messageEvent(slackBot: SlackBot, webApi: WebAPI, message: MessageDecorator, previous: MessageDecorator?) throws {
        guard let target = message.target, let sender = message.sender else { return }

        try message.routeText(
            to: self.sayHello(to: sender, in: target, with: webApi),
            allowingRemainder: true,
            matching: Greetings.all.any(name: "greeting"), ",".orNone, slackBot.me
        )

        try message.routeText(
            to: self.sayHello(to: sender, in: target, with: webApi),
            allowingRemainder: true,
            matching: slackBot.me, [":", ",", "!"].anyOrNone, Greetings.all.any(name: "greeting")
        )
    }
}

fileprivate extension HelloService {
    func sayHello(to sender: User, in target: SlackTargetType, with webApi: WebAPI) -> (PatternMatchResult) throws -> Void {
        return { match in
            let senderName = sender.messageSegment
            let greeting: String
            let defaultGreetings = ["Hi", "Hello", "hey"]
            switch (Greetings(rawValue: match.value(named: "greeting")) ?? Greetings.hey) {
            case .hi, .hello, .hey: greeting = "\(defaultGreetings.randomElement), \(senderName)"
            case .ohai: greeting = "ohai \(senderName)!"
            case .morning: greeting = "\((defaultGreetings + ["Good morning", "morning"]).randomElement), \(senderName)!"
            case .afternoon: greeting = "\((defaultGreetings + ["Good afternoon", "good afternoon"]).randomElement), \(senderName)!"
            case .evening: greeting = "\((defaultGreetings + ["Good evening", "good evening"]).randomElement), \(senderName)!"
            case .sup: greeting = "sup \(senderName)"
            case .going: greeting = [
                "Not bad, \(senderName), how's things for you?",
                "Pretty good, \(senderName). How about you?",
                "I'm incapable of complaints, \(senderName). How're you doing?",
                "\(defaultGreetings.randomElement), \(senderName)! I'm great, how've _you_ been?"].randomElement
            }
            let message = try SlackMessage()
                .line(greeting)
                .makeChatPostMessage(target: target)
            
            try webApi.execute(message)
        }
    }
}

fileprivate extension Array {
    var randomElement: Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
fileprivate enum Greetings: String {
    case hi
    case hello
    case hey
    case ohai
    case morning
    case afternoon
    case evening
    case sup
    case going

    static let all = [
        "hi", "hello", "hey", // defaults
        "ohai", "hai", // ohai
        "morning", "good morning", "mornin", "morning", "mornin'", "good mornin'", // morning
        "afternoon", "good afternoon", // afternoon
        "evenin", "evenin'", "evening", "good evening", "good evenin", "good evenin'", // evening
        "sup", "what's up", "'sup", // sup
        "how's it going", "how's it goin", "how's it goin'", "hows it goin", "hows it going", // going (pt 1)
        "how are you", "how're you", "how you doing", "how are you doing", "how are you doin", "how're you doin" // going (pt 2)
    ]

    init?(rawValue: String) {
        let rawValue = rawValue.lowercased()
        if rawValue == "hi" {
            self = .hi
        } else if rawValue == "hello" {
            self = .hello
        } else if rawValue == "hey" {
            self = .hey
        } else if rawValue == "ohai" || rawValue == "hai" {
            self = Greetings.ohai
        } else if ["morning", "good morning", "mornin", "morning", "mornin'", "good mornin'"].contains(rawValue) {
            self = .morning
        } else if ["afternoon", "good afternoon"].contains(rawValue) {
            self = .afternoon
        } else if ["evenin", "evenin'", "evening", "good evening", "good evenin", "good evenin'"].contains(rawValue) {
            self = .evening
        } else if ["sup", "what's up", "'sup"].contains(rawValue) {
            self = .sup
        } else if [
            "how's it going", "how's it goin", "how's it goin'", "hows it goin", "hows it going",
            "how are you", "how're you", "how you doing", "how are you doing", "how are you doin", "how're you doin"
            ].contains(rawValue) {
            self = .going
        } else {
            return nil
        }
    }
}
