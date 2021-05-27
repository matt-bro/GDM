//
//  ChatVCViewModel.swift
//  GDM
//
//  Created by Matt on 24.05.21.
//

import UIKit
import Combine

final class ChatVCViewModel: ViewModelType {

    struct Input {
        let didLoad: PassthroughSubject<Void, Never>
        //our input message text
        let messageText: AnyPublisher<String, Never>
        //when we tap send
        let tapSend: UIControl.EventPublisher
    }

    struct Output {
        let finishedLoadingFollowers: AnyPublisher<LoadingState, Never>
        let messages: AnyPublisher<[MessageCellViewModel], Never>
        let isMessageValid: AnyPublisher<Bool, Never>
        let sendMessage: AnyPublisher<String, Never>
        let updateMessages: AnyPublisher<Void, Never>
    }

    struct Dependencies {
        let api: API
        let db: Database
        let session: AppSession
    }

    private var cancellables = Set<AnyCancellable>()
    private let dependencies: Dependencies

    //loaded messages from db
    @Published private(set) var messages: [MessageEntity] = []
    //network loading state
    @Published private(set) var loadingState: LoadingState = .finished
    //text from input
    @Published private(set) var messageText: String = "Hello"

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func transform(input: Input) -> Output {

        let loadingState = $loadingState.eraseToAnyPublisher()

        //get our current ids from app session
        let currentUserId = dependencies.session.currentUserId
        let partnerId = dependencies.session.partnerId

        input.didLoad.sink(receiveValue: {
            self.messages = self.dependencies.db.getMessages(forUserId: currentUserId, partnerId: partnerId)
        }).store(in: &cancellables)

        //store our message text
        input.messageText.assign(to: \.messageText, on: self).store(in: &cancellables)

        //enable send btn if the is some message
        let isMessageValid = $messageText.map({ text -> Bool in
            return text.isEmpty == false
        }).eraseToAnyPublisher()

        //sending a message
        //triggers then a reply and loads finally all messages
        input.tapSend
            .flatMap({
                self.dependencies.api.send(message: self.messageText, toId: partnerId, self.dependencies.db)
            }).handleEvents(receiveSubscription: {_ in
                self.messages = self.dependencies.db.getMessages(forUserId: currentUserId, partnerId: partnerId)
            })
            .sink(receiveCompletion: {
                print($0)
            }, receiveValue: {
                print($0)
                self.messages = self.dependencies.db.getMessages(forUserId: currentUserId, partnerId: partnerId)
            })
        .store(in: &cancellables)

        //send our message
        let sendMessage = input.tapSend.map({ _ in
            self.messageText
        }).eraseToAnyPublisher()

        let updateMessages = self.dependencies.api.receivedMessagePublisher.handleEvents(receiveSubscription: {_ in
            self.messages = self.dependencies.db.getMessages(forUserId: currentUserId, partnerId: partnerId)
        }).map({ _ in }).eraseToAnyPublisher()

        //informs us about new messages and loads them
        self.dependencies.api.$receivedDate.sink(receiveValue: { _ in
            self.messages = self.dependencies.db.getMessages(forUserId: currentUserId, partnerId: partnerId)
        }).store(in: &cancellables)

        //the messages for our chat as view models
        let messages = $messages.map({ messageEntities in
            messageEntities.map({ e in
                MessageCellViewModel(id: Int(e.fromId), isMe: (e.fromId == currentUserId), message: e.text, date: e.sendDate)
            })
        }).eraseToAnyPublisher()

        return Output(finishedLoadingFollowers: loadingState, messages: messages, isMessageValid: isMessageValid, sendMessage: sendMessage, updateMessages: updateMessages)
    }
}
