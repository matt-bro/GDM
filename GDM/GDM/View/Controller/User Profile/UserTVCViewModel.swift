//
//  UserTVCViewModel.swift
//  GDM
//
//  Created by Matt on 26.05.21.
//

import UIKit
import Combine

final class UserTVCViewModel {
    struct Input {
        let didLoad: PassthroughSubject<Void, Never>
        //Refresh our data
        let refresh: PassthroughSubject<String?, Never>
        let didAppear: PassthroughSubject<Void, Never>
        //close our screen
        let pressedDone: PassthroughSubject<Void, Never>
        let userNameTextChanged: PassthroughSubject<String, Never>
    }

    struct Output {
        //user for our profile card
        let profileCardViewModel: AnyPublisher<ProfileCardViewModel, Never>
        let loadingState: AnyPublisher<Bool, Never>
        let canSwitch: AnyPublisher<Bool, Never>
    }

    struct Dependencies {
        let api: API
        let db: Database
        let nav: UserTVCNavigator
        let session: AppSession
    }

    private var cancellables = Set<AnyCancellable>()
    private let dependencies: Dependencies
    //store the user that we currently selected
    @Published private(set) var currentUser: UserEntity?
    @Published private(set) var loadingState: LoadingState = .finished

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func transform(input: Input) -> Output {
        self.currentUser = self.dependencies.db.user(forId: dependencies.session.currentUserId)

        //after pressing switchm we load a new user
        //empty user means there is something wrong with the name
        //if we go a user than we switch and reload all followers
        input.refresh.tryMap({ newUserName -> AnyPublisher<UserResponse, Error> in
            if let newUserName = newUserName {
                return self.dependencies.api.userDetail(for: newUserName, self.dependencies.db, nil, self.dependencies.session)
            } else {
                throw NSError(domain: "Invalid input", code: 42, userInfo: nil)
            }
        })
        .switchToLatest()
        //.flatMap(maxPublishers: .max(1)) {$0}
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure: self.loadingState = .error
            case .finished: print("Publisher is finished")
            }
        }, receiveValue: { _ in
            self.currentUser = self.dependencies.db.user(forId: self.dependencies.session.currentUserId)
        }).store(in: &cancellables)

        //map the current user to profileVM
        let profileCardViewModel = self.$currentUser.map({
            ProfileCardViewModel(userHandle: $0?.login, name: $0?.name, followers: Int($0?.followers ?? 0), following: Int($0?.following ?? 0), avatarUrl: $0?.avatarUrl)
        }).eraseToAnyPublisher()

        //dismiss our screen
        input.pressedDone.sink(receiveValue: {
            self.dependencies.nav.done()
        }).store(in: &cancellables)

        let loadingState = $loadingState.map({ $0 == .finished }).eraseToAnyPublisher()

        let canSwitch = input.userNameTextChanged.map({ $0.isEmpty == false }).eraseToAnyPublisher()
        return Output(profileCardViewModel: profileCardViewModel, loadingState: loadingState, canSwitch: canSwitch)
    }

    enum LoadingState {
        case finished
        case error
    }
}
