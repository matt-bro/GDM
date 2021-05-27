//
//  ChatVCViewModelTests.swift
//  GDMTests
//
//  Created by Matt on 27.05.21.
//
import Foundation
import Combine
import XCTest

@testable import GDM

private var cancellables: Set<AnyCancellable>!

class ChatVCViewModelTests: XCTestCase {

    private let didLoad = PassthroughSubject<Void, Never>()
    private var cancellables = [AnyCancellable]()

    let sendBtn = UIButton()
    let messageTv = UITextView()
    private let cancelSubject = PassthroughSubject<Void, Never>()

    override func setUp() {
        super.setUp()
    }

    func testViewModel() {
        let dependencies = ChatVCViewModel.Dependencies(api: MockAPI(), db: Database.shared, session: AppSession.shared)

        let vm =  ChatVCViewModel(dependencies: dependencies)
        let input = ChatVCViewModel.Input(didLoad: didLoad, messageText: messageTv.textPublisher(), tapSend: sendBtn.tapPublisher)

        let output = vm.transform(input: input)

        let loadingWorked = self.expectation(description: "loading worked")
        output.finishedLoadingFollowers.sink(receiveValue: { _ in
            loadingWorked.fulfill()
        }).store(in: &cancellables)

        let updateMessagesWorked = self.expectation(description: "valid message")
        output.isMessageValid.sink(receiveValue: { isValid in
            XCTAssertTrue(isValid)
            updateMessagesWorked.fulfill()
        }).store(in: &cancellables)


        wait(for: [loadingWorked, updateMessagesWorked], timeout: 5.0)
    }

}
