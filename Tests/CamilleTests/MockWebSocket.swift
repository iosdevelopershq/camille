import Foundation
import Dispatch
import Services

class MockWebSocket: WebSocket {
    private let group = DispatchGroup()
    private var onText: TextHandler?
    private var buffer: [[String: Any]] = []

    func popBuffer() -> [String: Any]? {
        let item = buffer.first
        buffer = Array(buffer.dropFirst())
        return item
    }
    func resetBuffer() {
        buffer.removeAll()
    }

    func connect(
        to url: String,
        onConnect: @escaping ConnectHandler,
        onDisconnect: @escaping DisconnectHandler,
        onText: @escaping TextHandler,
        onError: @escaping ErrorHandler
        ) throws
    {
        self.onText = onText

        group.enter()
        onConnect()
        group.wait()

        buffer.removeAll()
        onDisconnect()
    }

    func send(packet: [String: Any]) throws {
        buffer.append(packet)
        onText?(packet.makeString() ?? "")
    }

    func disconnect() {
        group.leave()
    }
}
