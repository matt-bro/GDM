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
        let refresh: PassthroughSubject<Bool, Never>
        let didAppear: PassthroughSubject<Void, Never>
        let pressedDone: PassthroughSubject<Void, Never>
    }

    struct Output {
        let profileCardViewModel: AnyPublisher<ProfileCardViewModel, Never>
    }

    struct Dependencies {
        let api: API
        let db: Database
        let nav: UserTVCNavigator
        let session: AppSession
    }

    private var cancellables = Set<AnyCancellable>()
    private let dependencies: Dependencies
    @Published private(set) var currentUser: UserEntity?
    @Published private(set) var loadingState: LoadingState = .finished

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func transform(input: Input) -> Output {
        self.currentUser = self.dependencies.db.user(forId: dependencies.session.currentUserId)
        input.didLoad.sink(receiveValue: { _ in

        }).store(in: &cancellables)

        input.refresh.map({ _ -> AnyPublisher<UserResponse, Error> in
            return self.dependencies.api.userDetail(for: self.dependencies.session.currentUserLogin, self.dependencies.db)
        })
        .switchToLatest()
        .sink(receiveCompletion: { _ in
            self.loadingState = .finished
        }, receiveValue: { _ in
            self.currentUser = self.dependencies.db.user(forId: self.dependencies.session.currentUserId)
        }).store(in: &cancellables)

        let profileCardViewModel = self.$currentUser.map({
            ProfileCardViewModel(userHandle: $0?.login, name: $0?.name, followers: Int($0?.followers ?? 0), following: Int($0?.following ?? 0), avatarUrl: $0?.avatarUrl)
        }).eraseToAnyPublisher()

        input.pressedDone.sink(receiveValue: {
            self.dependencies.nav.done()
        }).store(in: &cancellables)

        return Output(profileCardViewModel: profileCardViewModel)
    }

    enum LoadingState {
        case finished
        case error
    }
}
