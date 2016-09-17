import Models

/// Handler for the `team_join` event
public struct team_join: RTMAPIEvent {
    public typealias Parameters = (User)
    
    public static func make(withJson json: [String: Any], builderFactory: ([String: Any]) -> SlackModelBuilder) throws -> Parameters {
        let builder = builderFactory(json)
        return try builder.value(build: "user")
    }
}
