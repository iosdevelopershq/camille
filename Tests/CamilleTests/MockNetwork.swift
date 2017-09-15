import Foundation
import Dispatch
import Services

private struct MockResponse {
    let status: Int
    let data: Data?
}

private struct MockRequest {
    let path: String
    let body: [String: Any]
    let response: MockResponse

    func matches(_ request: NetworkRequest) throws -> Bool {
        let urlRequest = try request.buildURLRequest()

        guard
            let url = urlRequest.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            else { throw "Invalid url: \(urlRequest)" }

        guard components.path.replacingOccurrences(of: "/api/", with: "") == path else { return false }

        guard !body.isEmpty else { return true }

        let requestPairs = (request.body?.string.components(separatedBy: "&").flatMap({ $0.components(separatedBy: "=") }) ?? []).paired()

        //search the requestPairs for each pair required by this request
        for (key, value) in self.body {
            guard
                let match = requestPairs.first(where: { $0.key == key }),
                "\(match.value)" == "\(value)"
                else { return false }
        }

        return true
    }
}

class MockNetwork: Network {
    private var middleware: [NetworkMiddleware] = []
    private var requests: [MockRequest] = []

    func resetRequests() {
        requests.removeAll()
    }
    func addRequest(for path: String, body: [String: Any] = [:], status: Int = 200, data: Data? = nil) {
        let request = MockRequest(
            path: path,
            body: body,
            response: MockResponse(
                status: status,
                data: data
            )
        )
        requests.append(request)
    }
    func addRequest(for path: String, body: [String: Any] = [:], status: Int = 200, json: [String: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        addRequest(for: path, body: body, status: status, data: data)
    }

    func register(middleware: [NetworkMiddleware]) {
        self.middleware.append(contentsOf: middleware)
    }

    func perform(request: NetworkRequest, middleware: [NetworkMiddleware]) throws -> NetworkResponse {
        let urlRequest = try request.buildURLRequest()

        guard let mockResponse = try requests.first(where: { try $0.matches(request) })?.response
            else { throw "Response for \(request) not found" }

        let group = DispatchGroup()
        group.enter()

        let response = HTTPURLResponse(
            url: URL(string: request.url)!,
            statusCode: mockResponse.status,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!

        let combinedMiddleware = middleware + self.middleware

        var finalResult: NetworkMiddlewareResult?

        combinedMiddleware.handle(
            startingWith: .next(data: mockResponse.data),
            request: urlRequest,
            response: NetworkResponse(
                response: response,
                data: mockResponse.data
            ),
            complete: { result in
                finalResult = result
                group.leave()
            }
        )

        switch group.wait(wallTimeout: .now() + 30) {
        case .success:
            switch finalResult! {
            case .fail(let error):
                throw error
            case .retry:
                return try self.perform(request: request, middleware: middleware)
            case .next(let data):
                return NetworkResponse(
                    response: response,
                    data: data
                )
            }

        case .timedOut:
            throw NetworkError.timeout
        }
    }
}

extension Array {
    func paired() -> [(key: Element, value: Element)] {
        guard count % 2 == 0 else { return [] }

        return stride(from: startIndex, to: endIndex, by: 2)
            .map {
                let end = index($0, offsetBy: 2, limitedBy: endIndex) ?? endIndex
                let pair = Array(self[$0..<end])
                return (pair[0], pair[1])
            }
    }
}
