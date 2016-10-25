import Bot
import Sugar

extension KarmaService {
    func showUserKarma(user: User, from storage: Storage, in target: SlackTargetType,
                       with webApi: WebAPI) -> (PatternMatchResult) throws -> Void {
        
        return { match in
            let count: Int = storage.get(.in("Karma"), key: user.id, or: 0)
            
            let message = SlackMessage()
                .line(count == 0
                    ? ["It doesn't look like you have any karma yet ", user, ". Helping people out is a great way to get some!"]
                    : ["You have ", count, " karma ", user]
            )
            
            try webApi.execute(message.makeChatPostMessage(target: target))
        }
    }
}
