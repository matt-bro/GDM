//
//  ProfileCardViewModelTests.swift
//  GDM
//
//  Created by Matt on 27.05.21.
//

import Foundation
import Combine
import XCTest

@testable import GDM

private var cancellables: Set<AnyCancellable>!

class ProfileCardViewModelTests: XCTestCase {


    override func setUp() {
        super.setUp()
    }

    func testViewModel() {
        let vm = ProfileCardViewModel(userHandle: "matt-bro", name: "Matthias brodalka", followers: 15, following: 15, avatarUrl: "url")
        XCTAssertNotNil(vm.userHandle)
        XCTAssertNotNil(vm.name)
        XCTAssertNotNil(vm.avatarUrl)
        XCTAssertTrue(vm.followers == 15)
        XCTAssertTrue(vm.following == 15)

    }

}
