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
    private let refresh = PassthroughSubject<Bool, Never>()
    private var cancellables = [AnyCancellable]()
    private var emptyView: UIView?
    private var dataSource: GenericDataSource<CompactUserCell, CompactUserCellViewModel>?

    var activityBarBtn:UIBarItem {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let barButton = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.startAnimating()
        return barButton
    }

    let activityIndicator = UIActivityIndicatorView(style: .medium)


    func showIndicator() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }

    func hideIndicator() {
        self.activityIndicator.stopAnimating()
        self.navigationItem.leftBarButtonItem = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "main.title".ll

        let dependencies = UserListTVCViewModel.Dependencies(
            api: API.shared,
            db: Database.shared,
            nav: UserListTVCNavigator(navigationController: self.navigationController!),
            session: AppSession.shared
        )
        self.title = "@"+AppSession.shared.currentUserLogin

        self.viewModel = UserListTVCViewModel(dependencies: dependencies)

        self.setupTableView()
        self.bindViewModel()

        self.activityIndicator.hidesWhenStopped = true
        self.didLoad.send()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.didAppear.send()
    }

    func setupTableView() {
        self.tableView.register(UINib(nibName: CompactUserCell.identifier, bundle: nil), forCellReuseIdentifier: CompactUserCell.identifier)
        self.tableView.rowHeight = 70.0
        self.dataSource = GenericDataSource(cellIdentifier: CompactUserCell.identifier, items: [], configureCell: { (cell, vm) in
            //print(cell)
            cell.viewModel = vm
        })
        self.tableView.dataSource = dataSource

        self.emptyView = EmptyView.noFollowers()
    }

    func bindViewModel() {
        let input = UserListTVCViewModel.Input(didLoad: didLoad, selectRow: selectRow, refresh: refresh, didAppear: didAppear)
        let output = viewModel?.transform(input: input)

        output?.finishedLoadingFollowers.sink(receiveValue: {
            switch $0 {
            case .finished:
                self.hideIndicator()
                self.showEmptyView(show: false)
            case .error(let e):
                self.hideIndicator()
                self.showToast(message:"\("loading.error".ll)\(e.localizedDescription)")
                //self.showEmptyView(show: true, error: e)
            case .loading:
                self.showIndicator()
            case .empty:
                //self.hideIndicator()
                self.showEmptyView(show: true)
            }
            print($0)
        }).store(in: &cancellables)

        output?.followers.sink(receiveValue: { [unowned self] followers in
            self.dataSource?.items = followers
            self.tableView.reloadData()
            self.showEmptyView(show: followers.count == 0)
        }).store(in: &cancellables)
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
}

extension UserListTVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = self.dataSource?.items[indexPath.row] {
            self.selectRow.send(user.id)
        }
    }
}
