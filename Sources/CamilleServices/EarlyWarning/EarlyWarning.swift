import ChameleonKit

extension SlackBot {
    public enum EarlyWarning { }
}

extension SlackBot {
    public func enableEarlyWarning(config: EarlyWarning.Config) -> SlackBot {
        listen(for: .teamJoin) { bot, newUser in
            let user = try bot.lookup(newUser.id)

            guard let email = user.profile.email, let domain = email.components(separatedBy: "@").last else { return }

            var destination: Identifier<Channel>?

            if config.domains.contains(domain) { destination = config.alertChannel }
            else { destination = config.emailChannel }

            guard let channel = destination else { return }

            let ip = try? bot.perform(.teamAccessLogs(count: 20)).logins.first(where: { $0.user_id == user.id })?.ip
            let ipString = ip.map { " (IP: \($0))" } ?? ""

            try bot.perform(.speak(in: channel, "New user \(user) has joined with the email \(email)\(ipString)"))
        }

        return self
    }
}
