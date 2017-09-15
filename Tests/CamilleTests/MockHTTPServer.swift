import Foundation
import Services

class MockHTTPServer: HTTPServer {
    func start() throws {
        //
    }

    func register(_ method: HTTPMethod, path: [String], handler: @escaping RequestHandler) {
        //
    }
}
