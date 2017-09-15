
extension KarmaService {
    public struct Config {
        let topUserLimit: Int
        let positiveComments: [String]
        let negativeComments: [String]

        public init(topUserLimit: Int, positiveComments: [String], negativeComments: [String]) {
            self.topUserLimit = topUserLimit
            self.positiveComments = positiveComments
            self.negativeComments = negativeComments
        }

        public static func `default`() -> Config {
            return Config(
                topUserLimit: 10,
                positiveComments: ["you rock!"],
                negativeComments: ["booooo!"]
            )
        }
    }
}
