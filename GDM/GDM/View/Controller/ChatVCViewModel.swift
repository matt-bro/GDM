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
        let messageText: AnyPublisher<String, Never>
        let tapSend: UIControl.EventPublisher
    }

    struct Output {
        let finishedLoadingFollowers: AnyPublisher<LoadingState, Never>
        let messages: AnyPublisher<[MessageEntity], Never>
        let isMessageValid: AnyPublisher<Bool, Never>
        let sendMessage: AnyPublisher<String, Never>
        let updateMessages: AnyPublisher<Void, Never>
    }

    struct Dependencies {
        let api: API
        let db: Database
        let session: AppSessionProtocol
    }

    private var cancellables = Set<AnyCancellable>()
    private let dependencies: Dependencies
    @Published private(set) var messages: [MessageEntity] = []
    @Published private(set) var loadingState: LoadingState = .finished
    @Published private(set) var messageText: String = "Hallo"

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func transform(input: Input) -> Output {

        let loadingState = $loadingState.eraseToAnyPublisher()

        let currentUserId = dependencies.session.currentUserId
        let partnerId = dependencies.session.partnerId

        input.didLoad.sink(receiveValue: {
            self.messages = self.dependencies.db.getMessages(forUserId: currentUserId, partnerId: partnerId)
        }).store(in: &cancellables)

        input.messageText.assign(to: \.messageText, on: self).store(in: &cancellables)

        let isMessageValid = $messageText.map({ text -> Bool in
            return text.isEmpty == false
        }).eraseToAnyPublisher()

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

        let sendMessage = input.tapSend.map({ _ in
            self.messageText
        }).eraseToAnyPublisher()

        let updateMessages = self.dependencies.api.receivedMessagePublisher.handleEvents(receiveSubscription: {_ in
            self.messages = self.dependencies.db.getMessages(forUserId: currentUserId, partnerId: partnerId)
        }).map({ _ in }).eraseToAnyPublisher()

        self.dependencies.api.$receivedDate.sink(receiveValue: { _ in
            self.messages = self.dependencies.db.getMessages(forUserId: currentUserId, partnerId: partnerId)
        }).store(in: &cancellables)

        return Output(finishedLoadingFollowers: loadingState, messages: $messages.eraseToAnyPublisher(), isMessageValid: isMessageValid, sendMessage: sendMessage, updateMessages: updateMessages)
    }
}
