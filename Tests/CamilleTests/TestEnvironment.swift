import XCTest
import Dispatch
import Services
import Models
import Chameleon

typealias Environment = (storage: MemoryStorage, network: MockNetwork, socket: MockWebSocket)
typealias TestLoad = (Environment) -> [SlackBotService]
typealias TestStart = () -> Void
typealias TestExecution = (Environment) throws -> Void

func execute(
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    load: TestLoad,
    test: @escaping TestExecution
    ) throws
{
    do {
        let group = DispatchGroup()

        let storage = MemoryStorage()

        let authenticator = TokenAuthenticator(token: "token")

        let socket = MockWebSocket()

        let network = MockNetwork()
        try network.addRequest(for: "rtm.connect", json: WebAPIResponse.rtm_connect)
        try network.addRequest(for: "channels.info", body: ["channel": ModelIDs.channel1], json: WebAPIResponse.channels_info(id: ModelIDs.channel1, name: "channel"))
        try network.addRequest(for: "users.info", body: ["user": ModelIDs.mockUser1], json: WebAPIResponse.users_info(id: ModelIDs.mockUser1))
        try network.addRequest(for: "users.info", body: ["user": ModelIDs.mockUser2], json: WebAPIResponse.users_info(id: ModelIDs.mockUser2))
        network.addRequest(for: "chat.postMessage", status: 200)

        let webApi = WebAPI(network: network)
        let rtmApi = RTMAPI(socket: socket)

        let vendor = DefaultSlackModelTypeVendor(webApi: webApi)
        let config = SlackBot.Configuration(
            authenticator: authenticator,
            reconnectionStrategy: DefaultReconnectionStrategy(maxRetries: 5, delay: { _ in 0 }),
            modelVendor: vendor,
            verificationToken: nil
        )

        let env: Environment = (
            storage, network, socket
        )

        var bot: SlackBot!

        let tester = TestService(file: file, function: function, line: line) {
            try test(env)
            bot.stop()
        }

        let services = [tester] + load(env)

        bot = SlackBot(
            config: config,
            webApi: webApi,
            rtmApi: rtmApi,
            httpServer: MockHTTPServer(),
            services: services
        )

        group.enter()
        DispatchQueue.global().async {
            bot.start()
            group.leave()
        }

        group.wait()

    } catch let error {
        XCTFail("\(function): \(error)", file: file, line: line)
    }
}
