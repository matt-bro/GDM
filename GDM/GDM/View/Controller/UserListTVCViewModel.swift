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
        let selectRow: PassthroughSubject<String, Never>
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
            .sink(receiveCompletion: { completion in
                print(completion)
//                self.loadingState = .error(completion)
        }, receiveValue: { [unowned self] value in
            print(value)
            self.followers = dependencies.db.getFollowers()
            self.loadingState = .finished
        }).store(in: &cancellables)

        let loadingState = $loadingState.eraseToAnyPublisher()

        //lets map our follower user entities to a view model to present it
        let followers = $followers.map({
            $0.map({ CompactUserCellViewModel(title: $0.login, avatarUrl: $0.avatarUrl )} )
        }).eraseToAnyPublisher()

        input.selectRow.sink(receiveValue: { _ in
            self.dependencies.nav.toChat(userId: 1, parnterId: 2)
        }).store(in: &cancellables)

        return Output(finishedLoadingFollowers: loadingState, followers: followers)
    }
}
