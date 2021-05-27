//
//  UserListTVCTests.swift
//  GDM
//
//  Created by Matt on 27.05.21.
//

import Foundation
import Combine
import XCTest

@testable import GDM

private var cancellables: Set<AnyCancellable>!

class UserListTVCTests: XCTestCase {

    private let didLoad = PassthroughSubject<Void, Never>()
    private let didAppear = PassthroughSubject<Void, Never>()
    private let selectRow = PassthroughSubject<Int, Never>()
    private let pressedProfile = PassthroughSubject<Void, Never>()
    private let refresh = PassthroughSubject<Bool, Never>()
    private var cancellables = [AnyCancellable]()

    private let cancelSubject = PassthroughSubject<Void, Never>()

    override func setUp() {
        super.setUp()
    }

    func testViewModel() {
        let dependencies = UserListTVCViewModel.Dependencies(api: MockAPI(), db: Database.shared, nav: UserListTVCNavigator(navigationController: UINavigationController()), session: AppSession.shared)

        let vm =  UserListTVCViewModel(dependencies: dependencies)
        let input = UserListTVCViewModel.Input(didLoad: didLoad, selectRow: selectRow, refresh: refresh, didAppear: didAppear, pressedProfile: pressedProfile)

        let output = vm.transform(input: input)

        XCTAssertNoThrow(selectRow.send(0), "Selec row")


        let loadingWorked = self.expectation(description: "selectRow worked")
        output.finishedLoadingFollowers.sink(receiveValue: { _ in
            loadingWorked.fulfill()
        }).store(in: &cancellables)

        let followersWorked = self.expectation(description: "follower initial load worked")
        output.followers.sink(receiveValue: { _ in
            followersWorked.fulfill()
        }).store(in: &cancellables)

        wait(for: [loadingWorked, followersWorked], timeout: 5.0)
    }

}
