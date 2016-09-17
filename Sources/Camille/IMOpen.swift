import Models
import Services
import Common
import Foundation

/// Handler for the `im.open` endpoint
public class IMOpen: WebAPIMethod {
    public typealias SuccessParameters = (IM)
    
    //MARK: - Properties
    internal let user: User
    
    //MARK: - Lifecycle
    /**
     Creates a new `IMOpen` instance
     
     - parameter user:             The `User` to open a private im channel with
     
     - returns: A new instance
     */
    public init(user: User) {
        self.user = user
    }
    
    //MARK: - Public
    public var networkRequest: HTTPRequest {
        var packet = [String: Any]()
        
        packet = packet + [
            "user": self.user.id,
            "return_im": true
        ]
        
        let body: [String: Any]? = {
            var result = [String: Any]()
            for (key, value) in packet {
                result[key] = value as Any
            }
            return result
        }()
        
        return HTTPRequest(
            method: .post,
            url: WebAPIURL("im.open"),
            body: body
        )
    }
    public func handle(headers: [String: String], json: [String: Any], slackModels: SlackModels) throws -> SuccessParameters {
        guard let channel = json["channel"] as? [String: Any] else { throw WebAPIError.invalidResponse(json: json) }
        
        return try IM.makeModel(with: SlackModelBuilder(json: channel, models: slackModels))
    }
}
