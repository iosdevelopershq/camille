import Foundation
import Services
import Models

class SwiftDocSync {
    //MARK: - Properties
    private let http: HTTP
    private let storage: Storage
    private var api_urls = [String: String]()
    
    //MARK: - Lifecycle
    init(http: HTTP, storage: Storage) {
        self.http = http
        self.storage = storage
    }
    
    //MARK: - Public
    func updateDataset() throws {
        let request = HTTPRequest(method: .get, url: URL(string: "http://api.swiftdoc.org/api_urls")!)
        
        let (_, json) = try self.http.perform(with: request)
        
        var normalizedData = [String: String]()
        for (key, value) in json {
            guard let value = value as? String else { continue }
            normalizedData[key.lowercased()] = value
        }
        self.api_urls = normalizedData
    }
    func lookup(item: String) throws -> ModelType {
        guard let url = self.api_urls[item.lowercased()] else { throw SwiftDocError.itemNotFound(item: item) }
        
        let request = HTTPRequest(method: .get, url: URL(string: url)!)
        let (_, json) = try self.http.perform(with: request)
        
        guard let type = SwiftDocModel(json: json) else { throw SwiftDocError.itemNotFound(item: item) }
        
        let builder = ModelBuilder(json: json)
        return try type.modelType.makeModel(with: builder)
    }
}
