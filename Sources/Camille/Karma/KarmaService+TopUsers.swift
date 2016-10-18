import Bot
import Sugar

extension KarmaService {
    func showTopUsers(
        from storage: Storage, in target: SlackTargetType, with webApi: WebAPI,
        users: @autoclosure @escaping () -> [User]) -> (PatternMatchResult) throws -> Void {
        
        return { match in
            let count: Int = match.value(named: "count")
            
            guard count > 0 else {
                let message = SlackMessage().line("Top ", count, "? You must work in QA.")
                return try webApi.execute(message.makeChatPostMessage(target: target))
            }
            
            func karmaFor(user: User) -> Int {
                return storage.get(.in("Karma"), key: user.id, or: 0)
            }
            
            let karmaUsers = storage.allKeys(.in("Karma"))
                .flatMap { id in users().filter({ $0.id == id }) }
                .map { (user: $0, karma: karmaFor(user: $0)) }
                .sorted { $0.karma > $1.karma }
            
            let actualCount: Int
            let prefixText: String
            
            if count > self.config.topUsersLimit {
                actualCount = max(karmaUsers.count, self.config.topUsersLimit)
                prefixText = "Yeah, that's too many. Here's the top "
                
            } else if count > karmaUsers.count {
                actualCount = karmaUsers.count
                prefixText = "We only have "
                
            } else {
                actualCount = count
                prefixText = "Top "
            }
            
            let message = SlackMessage()
                .line(prefixText, actualCount, ":")
                .lines(for: karmaUsers) { message, entry in
                    return message.line(entry.user.name.bold, ": ", entry.karma)
            }
            
            try webApi.execute(message.makeChatPostMessage(target: target))
        }
    }
}
