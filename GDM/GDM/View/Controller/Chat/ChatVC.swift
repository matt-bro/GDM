//
//  ChatVC.swift
//  GDM
//
//  Created by Matt on 24.05.21.
//

import UIKit
import Combine

class ChatVC: UIViewController {

    var viewModel: ChatVCViewModel!
    private let didLoad = PassthroughSubject<Void, Never>()
    private var cancellables = [AnyCancellable]()
    private var dataSource: GenericDataSource<MessageCell, MessageCellViewModel>?

   // @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var inputContainerBottomSpace: NSLayoutConstraint!
    @IBOutlet var messageTV: UITextView!
    @IBOutlet var sendBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.bindViewModel()
        self.didLoad.send()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollToBottom()
    }

    func setupTableView() {
        self.tableView.register(UINib(nibName: MessageCell.identifier, bundle: nil), forCellReuseIdentifier: MessageCell.identifier)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 70.0
        self.dataSource = GenericDataSource(cellIdentifier: MessageCell.identifier, items: [], configureCell: { (cell, vm) in
            cell.viewModel = vm
        })
        self.tableView.dataSource = dataSource
        self.tableView.reloadData()
        self.scrollToBottom()
    }

    func bindViewModel() {
        let input = ChatVCViewModel.Input(didLoad: didLoad, messageText: messageTV.textPublisher(), tapSend: sendBtn.tapPublisher)
        let output = viewModel.transform(input: input)

        output.sendMessage.sink(receiveValue: {
            print("sending: \($0)")
            self.messageTV.resignFirstResponder()
            self.messageTV.text = ""
            self.sendBtn.isEnabled = false
            self.scrollToBottom()
        }).store(in: &cancellables)

        output.isMessageValid
            .assign(to: \.isEnabled, on: sendBtn)
            .store(in: &cancellables)

        output.messages.sink(receiveValue: {
            self.updateDataSource(items: $0)
        }).store(in: &cancellables)

        output.updateMessages.sink(receiveValue: {
            _ in
        }).store(in: &cancellables)

    }

    func updateDataSource(items: [MessageCellViewModel]) {
        self.dataSource?.items = items
        self.tableView.reloadData()
        self.scrollToBottom()
    }
}

extension ChatVC {
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.inputContainerBottomSpace.constant = keyboardFrame.size.height + 10
            })
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.inputContainerBottomSpace.constant = 5
            })
    }
    func scrollToBottom() {
        if let dataSourceItems = self.dataSource?.items, dataSourceItems.count > 0 {
            let indexPath = IndexPath(item: dataSourceItems.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: true)
        }
    }
}
