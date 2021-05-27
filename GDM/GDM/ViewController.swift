//
//  ViewController.swift
//  GDM
//
//  Created by Matt on 23.05.21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var dataSource: GenericDataSource<MessageCell, String>?
    var messages = [
        "This is a normal message",
        "This is a normal message\n2 Lines",
        "This is a normal message\n2 Lines\n3 lines"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.tableView.register(UINib(nibName: MessageCell.identifier, bundle: nil), forCellReuseIdentifier: "cell")
        self.dataSource = GenericDataSource(cellIdentifier: "cell", items: self.messages, configureCell: { (cell, val) in
            cell.messageType(isSentMessage: Int.random(in: 0..<3) > 1)
            cell.messageLabel?.numberOfLines = 0
            cell.messageLabel?.text = val

        })

        self.tableView.dataSource = dataSource
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50
    }

}
