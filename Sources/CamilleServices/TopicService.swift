//import Bot
//import Sugar
//
//typealias UserAllowedClosure = (User) -> Bool
//typealias TopicWarningClosure = (Channel, User) throws -> ChatPostMessage
//
//struct TopicServiceConfig {
//    let userAllowed: UserAllowedClosure
//    let warning: TopicWarningClosure?
//}
//
//final class TopicService: SlackRTMEventService, SlackConnectionService {
//    //MARK: - Properties
//    fileprivate let config: TopicServiceConfig
//    
//    //MARK: - Lifecycle
//    init(config: TopicServiceConfig) {
//        self.config = config
//    }
//    
//    //MARK: - Connection Event
//    func connected(slackBot: SlackBot, botUser: BotUser, team: Team, users: [User], channels: [Channel], groups: [Group], ims: [IM]) throws {
//        try self.updateTopics(for: channels, in: slackBot.storage)
//    }
//    
//    //MARK: - RTMAPI Events
//    func configureEvents(slackBot: SlackBot, webApi: WebAPI, dispatcher: SlackRTMEventDispatcher) {
//        dispatcher.onEvent(message.self) { data in
//            try self.messageEvent(slackBot: slackBot, webApi: webApi, message: data.message)
//        }
//        dispatcher.onEvent(channel_joined.self) { channel in
//            try self.updateTopics(for: [channel], in: slackBot.storage)
//        }
//    }
//}
//
////MARK: - Topic Sync
//fileprivate extension TopicService {
//    func updateTopics(for channels: [Channel], in storage: Storage) throws {
//        for channel in channels {
//            try storage.set(.in("topics"), key: channel.id, value: channel.topic?.value)
//        }
//    }
//}
//
////MARK: - Topic Updates
//fileprivate extension TopicService {
//    func messageEvent(slackBot: SlackBot, webApi: WebAPI, message: Message) throws {
//        guard
//            let subtype = message.subtype,
//            subtype == .channel_topic,
//            let topic = message.topic,
//            let user = message.user,
//            let channel = message.channel?.channel
//            else { return }
//        
//        if (self.config.userAllowed(user)) {
//            //update the stored topic
//            try slackBot.storage.set(.in("topics"), key: channel.id, value: topic)
//            
//        } else if let lastTopic: String = slackBot.storage.get(.in("topics"), key: channel.id) {
//            //reset the topic to the previous one set by an authorised user
//            let setTopic = ChannelSetTopic(channel: channel, topic: lastTopic)
//            _ = try webApi.execute(setTopic)
//            
//            //warn user if needed
//            guard let warning = self.config.warning else { return }
//            let message = try warning(channel, user)
//            _ = try webApi.execute(message)
//        }
//    }
//}
