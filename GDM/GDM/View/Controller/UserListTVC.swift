//
//  UserListTVC.swift
//  GDM
//
//  Created by Matt on 24.05.21.
//

import UIKit
import Combine

class UserListTVC: UITableViewController {

    private var viewModel:UserListTVCViewModel?
    private let didLoad = PassthroughSubject<Void, Never>()
    private let selectRow = PassthroughSubject<String, Never>()
    private var cancellables = [AnyCancellable]()
    private var dataSource: GenericDataSource<CompactUserCell, CompactUserCellViewModel>? {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "main.title".ll

        let dependencies = UserListTVCViewModel.Dependencies(
            api: MockAPI(),
            db: Database.shared,
            nav: UserListTVCNavigator(navigationController: self.navigationController!)
        )
        self.viewModel = UserListTVCViewModel(dependencies: dependencies)

        self.setupTableView()
        self.bindViewModel()
    }

    func setupTableView() {
        self.tableView.register(UINib(nibName: CompactUserCell.identifier, bundle: nil), forCellReuseIdentifier: CompactUserCell.identifier)
        self.tableView.rowHeight = 70.0
        self.dataSource = GenericDataSource(cellIdentifier: CompactUserCell.identifier, items: [], configureCell: { (cell, vm) in
            //print(cell)
            cell.viewModel = vm
        })
        self.tableView.dataSource = dataSource
    }

    func bindViewModel() {
        let input = UserListTVCViewModel.Input(didLoad: didLoad, selectRow: selectRow)
        let output = viewModel?.transform(input: input)

        output?.finishedLoadingFollowers.sink(receiveValue: {
            print($0)
        }).store(in: &cancellables)

        output?.followers.sink(receiveValue: { [unowned self] followers in
            self.dataSource?.items = followers
            self.tableView.reloadData()
        }).store(in: &cancellables)
    }
}

extension UserListTVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = self.dataSource?.items[indexPath.row] {
            self.selectRow.send("1")
        }
    }
}
