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
    }

    struct Dependencies {
        let api: API
        let db: Database
    }

    private var cancellables = Set<AnyCancellable>()
    private let dependencies: Dependencies
    @Published private(set) var messages: [MessageEntity] = []
    @Published private(set) var loadingState: LoadingState = .finished
    @Published private(set) var messageText: String = ""

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func transform(input: Input) -> Output {

        let loadingState = $loadingState.eraseToAnyPublisher()

        input.didLoad.sink(receiveValue: {
            self.messages = self.dependencies.db.getMessages(forUserId: 999, partnerId: 111)
        }).store(in: &cancellables)

        //lets map our follower user entities to a view model to present it
//        let followers = $messages.map({
//            $0.map({ CompactUserCellViewModel(title: $0.login, avatarUrl: $0.avatarUrl )} )
//        }).eraseToAnyPublisher()

        input.messageText.assign(to: \.messageText, on: self).store(in: &cancellables)
//
//        input.messageText.sink(receiveValue: {
//            print($0)
//        }).store(in: &cancellables)
//        
        let isMessageValid = $messageText.map({ text -> Bool in
            return text.isEmpty == false
        }).eraseToAnyPublisher()

       // input.messageText.assign(to: \.messageText, on: self).store(in: &cancellables)

//        input.tapSend.combineLatest(self.dependencies.api.send(message: "", toId: 1)).sink(receiveValue: { _ in
//            self.messages = self.dependencies.db.getMessages(forUserId: 999, partnerId: 111)
//        }).store(in: &cancellables)
//        input.tapSend.handleEvents(receiveSubscription: { _ in
//            self.dependencies.api.send(message: self.messageText, toId: 999)
//        }).sink(receiveValue: {
//            self.messages = self.dependencies.db.getMessages(forUserId: 999, partnerId: 111)
//        }).store(in: &cancellables)

        input.tapSend.flatMap({ self.dependencies.api.send(message: self.messageText, toId: 999, self.dependencies.db) })
            .sink(receiveValue: { _ in
                self.messages = self.dependencies.db.getMessages(forUserId: 999, partnerId: 111)
        }).store(in: &cancellables)

        let sendMessage = input.tapSend.map({ _ in
            self.messageText
        }).eraseToAnyPublisher()

        return Output(finishedLoadingFollowers: loadingState, messages: $messages.eraseToAnyPublisher(), isMessageValid: isMessageValid, sendMessage: sendMessage)
    }
}
