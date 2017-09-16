//
//enum CrossPostButton: String {
//    case privateWarning
//    case publicWarning
//    case removeAll
//    
//    var text: String {
//        switch self {
//        case .privateWarning: return "Private Warning"
//        case .publicWarning: return "Public Warning"
//        case .removeAll: return "Remove all posts"
//        }
//    }
//    
//    var afterExecuted: [CrossPostButton] {
//        switch self {
//        case .privateWarning: return [.removeAll]
//        case .publicWarning: return [.removeAll]
//        case .removeAll: return [.privateWarning, .publicWarning]
//        }
//    }
//    
//    static var all: [CrossPostButton] { return [.privateWarning, .publicWarning, .removeAll] }
//}
