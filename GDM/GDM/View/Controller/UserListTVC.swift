//
//  UserListTVC.swift
//  GDM
//
//  Created by Matt on 24.05.21.
//

import UIKit
import Combine

class UserListTVC: UITableViewController {

    private var viewModel = UserListTVCViewModel(dependencies: UserListTVCViewModel.Dependencies(api: MockAPI(), db: Database.shared))
    private let didLoad = PassthroughSubject<Void, Never>()
    private var cancellables = [AnyCancellable]()
    private var dataSource: GenericDataSource<CompactUserCell, CompactUserCellViewModel>? {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "main.title".ll

        self.setupTableView()
        self.bindViewModel()
    }

    func setupTableView() {
        self.tableView.register(UINib(nibName: CompactUserCell.identifier, bundle: nil), forCellReuseIdentifier: CompactUserCell.identifier)
        self.tableView.rowHeight = 70.0
        self.dataSource = GenericDataSource(cellIdentifier: CompactUserCell.identifier, items: [], configureCell: { (cell, vm) in
            print(cell)
            cell.viewModel = vm
        })
        self.tableView.dataSource = dataSource
    }

    func bindViewModel() {
        let input = UserListTVCViewModel.Input(didLoad: didLoad)
        let output = viewModel.transform(input: input)

        output.finishedLoadingFollowers.sink(receiveValue: {
            print($0)
        }).store(in: &cancellables)

        output.followers.sink(receiveValue: { [unowned self] followers in
            self.dataSource?.items = followers
            self.tableView.reloadData()
        }).store(in: &cancellables)
    }
}
