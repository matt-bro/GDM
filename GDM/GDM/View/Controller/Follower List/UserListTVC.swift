//
//  UserListTVC.swift
//  GDM
//
//  Created by Matt on 24.05.21.
//

import UIKit
import Combine

class UserListTVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    private var viewModel: UserListTVCViewModel?

    private let didLoad = PassthroughSubject<Void, Never>()
    private let didAppear = PassthroughSubject<Void, Never>()
    private let selectRow = PassthroughSubject<Int, Never>()
    private let pressedProfile = PassthroughSubject<Void, Never>()
    private let refresh = PassthroughSubject<Bool, Never>()
    private var cancellables = [AnyCancellable]()
    private var emptyView: UIView?

    private var dataSource: GenericDataSource<CompactUserCell, CompactUserCellViewModel>?

    let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "@"+AppSession.shared.currentUserLogin

        let dependencies = UserListTVCViewModel.Dependencies(
            api: API.shared,
            db: Database.shared,
            nav: UserListTVCNavigator(navigationController: self.navigationController!),
            session: AppSession.shared
        )

        self.viewModel = UserListTVCViewModel(dependencies: dependencies)

        self.setupTableView()
        self.bindViewModel()
        self.didLoad.send()
        self.activityIndicator.hidesWhenStopped = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.didAppear.send()
    }

    func setupTableView() {
        self.tableView.register(UINib(nibName: CompactUserCell.identifier, bundle: nil), forCellReuseIdentifier: CompactUserCell.identifier)
        self.tableView.rowHeight = 70.0
        self.dataSource = GenericDataSource(cellIdentifier: CompactUserCell.identifier, items: [], configureCell: { (cell, vm) in
            cell.viewModel = vm
        })
        self.tableView.dataSource = dataSource
        self.emptyView = EmptyView.noFollowers()
    }

    func bindViewModel() {
        let input = UserListTVCViewModel.Input(
            didLoad: didLoad,
            selectRow: selectRow,
            refresh: refresh,
            didAppear: didAppear,
            pressedProfile: pressedProfile
        )
        let output = viewModel?.transform(input: input)

        //after we loaded our followers hide activity indicator
        //on error we show a toast
        //on empty we show an empty screen
        output?.finishedLoadingFollowers.sink(receiveValue: {
            switch $0 {
            case .finished:
                self.hideIndicator()
                self.showEmptyView(show: false)
            case .error(let e):
                self.hideIndicator()
                self.showToast(message: "\("loading.error".ll)\(e.localizedDescription)")
            case .loading:
                self.showIndicator()
            case .empty:
                self.showEmptyView(show: true)
            }
        }).store(in: &cancellables)

        //after we got new followers we need to update our datasource
        //if its empty show an empty screen
        output?.followers.sink(receiveValue: { [unowned self] followers in
            self.dataSource?.items = followers
            self.tableView.reloadData()
            self.showEmptyView(show: followers.count == 0)
        }).store(in: &cancellables)

        //user change needs to update title
        output?.userChanged.sink(receiveValue: {
            self.title = "@\($0)"
        }).store(in: &cancellables)
    }

}

extension UserListTVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = self.dataSource?.items[indexPath.row] {
            self.selectRow.send(user.id)
        }
    }
}

extension UserListTVC {
    @IBAction func pressedUserProfile() {
        self.pressedProfile.send()
    }

    func showEmptyView(show: Bool, error: Error? = nil) {
        guard let emptyView = self.emptyView else {
            return
        }
        if show {
            self.tableView.backgroundView = emptyView
            self.tableView.separatorColor = .clear
        } else {
            self.tableView.backgroundView = nil
            self.tableView.separatorColor = .lightGray
        }
    }

    func showIndicator() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }

    func hideIndicator() {
        self.activityIndicator.stopAnimating()
        self.navigationItem.leftBarButtonItem = nil
    }
}
