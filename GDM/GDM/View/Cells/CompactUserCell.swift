//
//  CompactUserCell.swift
//  GDM
//
//  Created by Matt on 24.05.21.
//

import UIKit

class CompactUserCell: UITableViewCell {

    static let identifier = "CompactUserCell"

    @IBOutlet var avatarIV: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var stackView: UIStackView!

    var viewModel: CompactUserCellViewModel? {
        didSet {
            setupViewModel()
        }
    }

    let testImageIV = UIImageView()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.accessoryType = .disclosureIndicator
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupViewModel() {
        self.titleLabel?.text = viewModel?.handle
        self.subtitleLabel?.text = viewModel?.subtitle
        self.dateLabel?.text = viewModel?.date
        self.stackView.isHidden = (viewModel?.subtitle?.isEmpty ?? true)

        //load profile image
        if let avatarUrl = viewModel?.avatarUrl {
            self.avatarIV?.loadImageUsingCacheWithURLString(avatarUrl.absoluteString, placeHolder: #imageLiteral(resourceName: "avatar"), completion: { [unowned self] _ in
                self.avatarIV?.applyCircleShape()
            })
        }
    }

}
