//
//  UserTVC.swift
//  GDM
//
//  Created by Matt on 26.05.21.
//

import UIKit
import Combine

class UserTVC: UITableViewController {

    var viewModel: UserTVCViewModel!
    private var cancellables = [AnyCancellable]()
    private let didLoad = PassthroughSubject<Void, Never>()
    private let refresh = PassthroughSubject<String?, Never>()
    private let didAppear = PassthroughSubject<Void, Never>()
    private let done = PassthroughSubject<Void, Never>()
    private let pressedSwitch = PassthroughSubject<Void, Never>()
    let userNameText = PassthroughSubject<String, Never>()

    @IBOutlet var switchBtn: UIButton!
    @IBOutlet var userNameTf: UITextField!
    @IBOutlet var errorLabel: UILabel!

    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var followersLabel: UILabel!
    @IBOutlet var followingLabel: UILabel!
    @IBOutlet var avatarImage: UIImageView!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.bindViewModel()
        self.didLoad.send()
    }

    func bindViewModel() {
        let input = UserTVCViewModel.Input(didLoad: didLoad, refresh: refresh, didAppear: didAppear, pressedDone: done, userNameTextChanged: userNameText)
        let output = viewModel.transform(input: input)

        output.profileCardViewModel.sink(receiveValue: { [unowned self] vm in
            self.userNameLabel.text = vm.userHandle
            self.nameLabel.text = vm.name
            self.followersLabel.text = vm.followersString
            self.followingLabel.text = vm.followingString

            if let avatarUrl = vm.avatarUrl {
                self.avatarImage?.loadImageUsingCacheWithURLString(avatarUrl, placeHolder: #imageLiteral(resourceName: "avatar"), completion: { _ in
                })
            }
        }).store(in: &cancellables)

        switchBtn.tapPublisher.sink(receiveValue: { [unowned self] _ in
            if let userName = self.userNameTf.text, userName.isEmpty == false {
                AppSession.shared.currentUserLogin = userName
                self.refresh.send(userName)
            }
        }).store(in: &cancellables)

        self.userNameTf.textPublisher()
            .sink(receiveValue: { [unowned self] text in
                    self.userNameText.send(text)} )
            .store(in: &cancellables)

        output.loadingState.sink(receiveValue: { [unowned self] hasError in
            self.showError(hasError)
        }).store(in: &cancellables)

        output.canSwitch.sink(receiveValue: { [unowned self] canSwitch in
            self.switchBtn.isEnabled = canSwitch
        }).store(in: &cancellables)
    }
}

extension UserTVC {
    @IBAction func pressedDone() {
        done.send()
    }

    func showError(_ show: Bool) {
        if show {
            self.errorLabel.isHidden = true
            return
        }

        self.errorLabel.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            self.errorLabel.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                self.errorLabel.alpha = 0.0
            }, completion: {_ in
                self.errorLabel.isHidden = true
            })
        })
    }
}
