//
//  UserListTVCViewModel.swift
//  GDM
//
//  Created by Matt on 24.05.21.
//
import UIKit
import Combine

enum LoadingState {
    case loading
    case finished
    case empty
    case error(Error)
}

final class UserListTVCViewModel: ViewModelType {

    struct Input {
        let didLoad: PassthroughSubject<Void, Never>
        let selectRow: PassthroughSubject<Int, Never>
    }

    struct Output {
        let finishedLoadingFollowers: AnyPublisher<LoadingState, Never>
        let followers: AnyPublisher<[CompactUserCellViewModel], Never>
    }

    struct Dependencies {
        let api: API
        let db: Database
        let nav: UserListTVCNavigatable
    }

    private var cancellables = Set<AnyCancellable>()
    private let dependencies: Dependencies
    @Published private(set) var followers: [UserEntity] = []
    @Published private(set) var loadingState: LoadingState = .finished

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func transform(input: Input) -> Output {

        dependencies.api.followers(for: "matt-bro", self.dependencies.db)
            .dropFirst()
            .sink(receiveCompletion: { completion in
                print(completion)
//                self.loadingState = .error(completion)
        }, receiveValue: { [unowned self] value in
            print(value)
            self.followers = dependencies.db.getFollowers()
            self.loadingState = .finished
        }).store(in: &cancellables)

        self.followers = dependencies.db.getFollowers()

        let loadingState = $loadingState.eraseToAnyPublisher()

        //lets map our follower user entities to a view model to present it
        let followers = $followers.map({
            $0.map({ CompactUserCellViewModel(id: Int($0.id), title: $0.login, avatarUrl: $0.avatarUrl )} )
        }).eraseToAnyPublisher()

        input.selectRow.sink(receiveValue: { userId in
            if userId != -1 {
                let partnerUser = self.dependencies.db.user(forId: userId)
                self.dependencies.nav.toChat(userId: AppSession.shared.currentUserId, partnerId: userId, partnerName: partnerUser?.login)
            }
        }).store(in: &cancellables)

        return Output(finishedLoadingFollowers: loadingState, followers: followers)
    }
}
