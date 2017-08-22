import Chameleon

extension KarmaService {
    enum Patterns: HelpRepresentable {
        case topUsers
        case myCount
        case userCount
        case adjustment

        var topic: String {
            return "Karma"
        }
        var description: String {
            switch self {
            case .topUsers: return "Find out who's on top!"
            case .myCount: return "See how much karma you have"
            case .userCount: return "See how much karma someone else has"
            case .adjustment: return "Give or take karma from someone"
            }
        }

        var pattern: [Matcher] {
            switch self {
            case .topUsers: return ["top", Int.any.using(key: Keys.count)]
            case .myCount: return ["how much karma do I have"]
            case .userCount: return ["how much karma does", User.any.using(key: Keys.user), "have"]
            case .adjustment: return [User.any, Operation.values.any]
            }
        }

        var strict: Bool { return false }
    }
}
