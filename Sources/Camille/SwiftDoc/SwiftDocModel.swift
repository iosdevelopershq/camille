import Models

enum SwiftDocModel: String {
    case `operator`
    case `protocol`
    case `struct`
    case `class`
    case `enum`
    //case `extension`
    case operator_func
    case `func`
    case `init_`
    case `deinit`
    case `subscript`
    case `typealias`
    case `case`
    case `var`
    
    var modelType: ModelType.Type {
        switch self {
        case .operator: return Operator.self
        case .protocol: return Protocol.self
        case .struct, .class, .enum: return Type.self
        //case .extension: return Extension.self
        case .operator_func: return OperatorFunction.self
        case .func: return Function.self
        case .init_: return Init.self
        case .deinit: return Deinit.self
        case .subscript: return Subscript.self
        case .typealias: return Typealias.self
        case .case: return Case.self
        case .var: return Property.self
        }
    }
    
    init?(json: [String: Any]) {
        guard let type = json["kind"] as? String else { return nil }
        
        let rawValueString = type.components(separatedBy: "_").joined(separator: " ")
        guard let result = SwiftDocModel(rawValue: rawValueString) else { return nil }
        
        self = result
    }
}
