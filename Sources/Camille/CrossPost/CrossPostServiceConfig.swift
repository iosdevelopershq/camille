import Bot
import Sugar
import Foundation

struct CrossPostServiceConfig {
    let timeSpan: TimeInterval
    let includeMessage: (MessageDecorator) -> Bool
    let reportingTarget: String
    let publicWarning: (SlackTargetType, User) throws -> ChatPostMessage
    let privateWarning: (IM) throws -> ChatPostMessage
}
