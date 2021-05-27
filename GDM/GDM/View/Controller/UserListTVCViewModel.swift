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
        //selected a follower
        let selectRow: PassthroughSubject<Int, Never>
        //Refresh our data
        let refresh: PassthroughSubject<Bool, Never>
        let didAppear: PassthroughSubject<Void, Never>
        //pressed go to profile
        let pressedProfile: PassthroughSubject<Void, Never>
    }

    struct Output {
        let finishedLoadingFollowers: AnyPublisher<LoadingState, Never>
        let followers: AnyPublisher<[CompactUserCellViewModel], Never>
        let userChanged: AnyPublisher<String , Never>
    }

    struct Dependencies {
        let api: API
        let db: Database
        let nav: UserListTVCNavigatable
        let session: AppSession
    }

    private var cancellables = Set<AnyCancellable>()
    private let dependencies: Dependencies
    //our followers
    @Published private(set) var followers: [UserEntity] = []
    //network loading state
    @Published private(set) var loadingState: LoadingState = .finished

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func transform(input: Input) -> Output {


        let loadingState = $loadingState.eraseToAnyPublisher()

        dependencies.session.$currentUserLogin.dropFirst().sink(receiveValue: { _ in
            self.followers = self.dependencies.db.getFollowers(self.dependencies.session.currentUserLogin)
            input.refresh.send(true)
        }).store(in: &cancellables)

        if self.dependencies.db.me() == nil {
            dependencies.api.userDetail(for: self.dependencies.session.currentUserLogin, self.dependencies.db, nil, self.dependencies.session)
                .sink(receiveCompletion: {_ in }, receiveValue: { _ in}).store(in: &cancellables)
        }

        //we need to reload ui after user changes
        let userChanged = self.dependencies.session.$currentUserLogin.eraseToAnyPublisher()

        //load our followers
        input.refresh.map({ _ -> AnyPublisher<[UserResponse], Error> in
            self.loadingState = .loading
            return self.dependencies.api.followers(for: self.dependencies.session.currentUserLogin, self.dependencies.db)
        })
        .switchToLatest()
        .sink(receiveCompletion: { completion in
        switch completion {
            case .failure(let error): self.loadingState = .error(error)
            case .finished: print("Publisher is finished")
            }
        }, receiveValue: { [unowned self] value in
            self.followers = dependencies.db.getFollowers(self.dependencies.session.currentUserLogin)
            self.loadingState = .finished
        }).store(in: &cancellables)

        input.refresh.send(true)

        //go to user profile screen
        input.pressedProfile.sink(receiveValue: {
            self.dependencies.nav.toUserProfile()
        }).store(in: &cancellables)

        //load offline data initially if it exists
        input.didLoad.combineLatest(input.didAppear).sink(receiveValue: {
            _ in

            self.followers = self.dependencies.db.getFollowers(self.dependencies.session.currentUserLogin)
            if self.followers.count == 0 {
                self.loadingState = .empty
            }

        }).store(in: &cancellables)

        //lets map our follower user entities to a view model to present it
        let followers = $followers.map({
            $0.map({
                CompactUserCellViewModel(id: Int($0.id), title: $0.login, avatarUrl: $0.avatarUrl, subtitle: $0.lastMessagePrev, date: $0.lastMessageDate?.string )
            })
        }).eraseToAnyPublisher()

        input.selectRow.sink(receiveValue: { userId in
            if userId != -1 {
                let partnerUser = self.dependencies.db.user(forId: userId)
                self.dependencies.nav.toChat(userId: AppSession.shared.currentUserId, partnerId: userId, partnerName: partnerUser?.login)
            }
        }).store(in: &cancellables)

        return Output(finishedLoadingFollowers: loadingState, followers: followers, userChanged: userChanged)
    }
}
