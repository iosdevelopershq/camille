import Bot
import Sugar

extension KarmaService {
    func adjustKarma(
        in message: MessageDecorator,
        from sender: User,
        in target: SlackTargetType,
        storage: Storage,
        webApi: WebAPI) throws -> Void {
        
        //find any karma adjustments
        let adjustments: [(user: User, amount: Int)] = message.mentioned_users.flatMap { link in
            //user can't adjust their own karma
            guard link.value != sender else { return nil }
            
            //Move past the `>` and get the rest of the message
            let start = message.text.index(after: link.range.upperBound)
            let text = message.text.substring(from: start)
            
            //iterate forward until we pass the threshold or hit the end of the string
            for index in (0..<min(self.config.textDistanceThreshold, text.characters.count)) {
                //check for adjustments
                for adjuster in self.config.karmaAdjusters {
                    if text.substring(from: index).hasPrefix(adjuster.adjuster.karmaValue) {
                        return (link.value, adjuster.amount)
                    }
                }
                
                //check the allowed chars
                let nextChar = Character(text.substring(to: 1))
                guard self.config.allowedBufferCharacters.contains(nextChar) else { break }
            }
            
            return nil
        }
        
        guard !adjustments.isEmpty else { return }
        
        //consolidate adjustments
        let consolidated: [(user: User, change: Int, total: Int)] = adjustments
            .grouped(by: { $0.user })
            .flatMap { user, changes in
                let current: Int = storage.get(.in("Karma"), key: user.id, or: 0)
                let change = changes.reduce(0) { $0 + $1.amount }
                guard change != 0 else { return nil }
                let newTotal = current + change
                return (user, change, newTotal)
        }
        
        //make adjustments
        for adjustment in consolidated where adjustment.change != 0 {
            try storage.set(.in("Karma"), key: adjustment.user.id, value: adjustment.total)
        }
        
        //build a message
        let response = consolidated
            .flatMap { adjustment in
                if adjustment.change > 0 {
                    return self.config.positiveMessage(adjustment.user, adjustment.total).randomElement
                } else if adjustment.change < 0 {
                    return self.config.negativeMessage(adjustment.user, adjustment.total).randomElement
                }
                return nil
            }
            .joined(separator: "\n")
        
        guard !response.isEmpty else { return }
        
        //respond
        let request = ChatPostMessage(target: target, text: response)
        try webApi.execute(request)
    }
}
