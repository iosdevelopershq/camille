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

            try bot.perform(.speak(in: channel, "New user \(user) has joined with the email \(email)"))
        }

        return self
    }
}
