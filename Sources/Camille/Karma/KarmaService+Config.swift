import Sugar
import Models

extension KarmaService {
    struct Config {
        let topUsersLimit: Int
        let karmaAdjusters: [(adjuster: KarmaAdjustable, amount: Int)]
        let textDistanceThreshold: Int
        let allowedBufferCharacters: Set<Character>
        let positiveMessage: (_ user: User, _ total: Int) -> [String]
        let negativeMessage: (_ user: User, _ total: Int) -> [String]
    }
}
