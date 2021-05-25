//
//  MessageCell.swift
//  GDM
//
//  Created by Matt on 25.05.21.
//

import UIKit

class MessageCell: UITableViewCell {

    static let identifier = "MessageCell"

    @IBOutlet var bubbleImageView: UIImageView!
    @IBOutlet var messageLabel: UILabel!

    @IBOutlet var messageLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var messageLabelTrailingConstraint: NSLayoutConstraint!

    var viewModel: MessageCellViewModel? {
        didSet {
            self.setupViewModel()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func messageType(isSentMessage: Bool) {
        if isSentMessage {
            messageLabelLeadingConstraint.isActive = false
            messageLabelTrailingConstraint.isActive = true
            self.changeImage("right_bubble")
        } else {
            messageLabelLeadingConstraint.isActive = true
            messageLabelTrailingConstraint.isActive = false
            self.changeImage("left_bubble")
        }
    }

    func changeImage(_ name: String) {
        guard let image = UIImage(named: name) else { return }
        bubbleImageView.image = image
            .resizableImage(withCapInsets:
                                UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),
                                    resizingMode: .stretch)
    }

    func setupViewModel() {
        self.messageLabel.text = viewModel?.message
        self.messageType(isSentMessage: viewModel?.isMe ?? false)
    }
    
}
