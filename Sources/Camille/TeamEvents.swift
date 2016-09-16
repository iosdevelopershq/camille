import Models

/// Handler for the `team_join` event
public struct team_join: RTMAPIEvent {
    public typealias Parameters = (User)
    
    public static func make(withJson json: [String: Any], builderFactory: ([String: Any]) -> SlackModelBuilder) throws -> Parameters {
        let builder = builderFactory(json)
        print("\n\n\n\(builder)\n\n\n")
        let user: User = try builder.value(build: "user")
        return user
    }
}
