
enum SwiftDocError: Error, CustomStringConvertible {
    case itemNotFound(item: String)
    case unableToDisplay(item: String)
    
    var description: String {
        switch self {
        case .itemNotFound(let item): return "Unable to find item: \(item)"
        case .unableToDisplay(let item): return "Found \(item) but unable to convert to Slack message"
        }
    }
}
