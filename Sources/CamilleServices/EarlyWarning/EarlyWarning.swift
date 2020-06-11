import ChameleonKit

extension SlackBot {
    public enum EarlyWarning { }
}

extension SlackBot {
    public func enableEmailFilter(config: EarlyWarning.Config) -> SlackBot {
        listen(for: .teamJoin) { bot, user in
            guard
                let email = user.profile.email,
                let domain = email.components(separatedBy: "@").last,
                config.domains.contains(domain)
                else { return }

            try bot.perform(.speak(in: config.channel, "New user \(user) has joined with the email \(email)"))
        }

        return self
    }
}
