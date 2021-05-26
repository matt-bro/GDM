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
    private let didLoad = PassthroughSubject<Void, Never>()
    private let refresh = PassthroughSubject<Bool, Never>()
    private var cancellables = [AnyCancellable]()
    private var dataSource: GenericDataSource<MessageCell, MessageCellViewModel>?
    private let didAppear = PassthroughSubject<Void, Never>()

    @IBOutlet var switchBtn: UIButton!
    @IBOutlet var userNameTf: UITextField!

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
        let input = UserTVCViewModel.Input(didLoad: didLoad, refresh: refresh, didAppear: didAppear)
        let output = viewModel.transform(input: input)

        output.profileCardViewModel.sink(receiveValue: { vm in
            self.userNameLabel.text = vm.userHandle
            self.nameLabel.text = vm.name
            self.followersLabel.text = vm.followersString
            self.followingLabel.text = vm.followingString

            if let avatarUrl = vm.avatarUrl {
                self.avatarImage?.loadImageUsingCacheWithURLString(avatarUrl, placeHolder: #imageLiteral(resourceName: "avatar"), completion: { [unowned self] succes in
                    //self.avatarImage?.applyCircleShape()
                })
            }
        }).store(in: &cancellables)

        switchBtn.tapPublisher.sink(receiveValue: {
            AppSession.shared.currentUserLogin = self.userNameTf.text ?? ""
            self.refresh.send(true)
        }).store(in: &cancellables)
    }


}
