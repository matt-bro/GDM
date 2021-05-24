//
//  CompactUserCell.swift
//  GDM
//
//  Created by Matt on 24.05.21.
//

import UIKit

class CompactUserCell: UITableViewCell {

    static let identifier = "CompactUserCell"

    var viewModel: CompactUserCellViewModel? {
        didSet {
            setupViewModel()
        }
    }

    let testImageIV = UIImageView()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView?.applyCircleShape()
        self.accessoryType = .disclosureIndicator
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupViewModel() {
        self.textLabel?.text = viewModel?.title
        if let avatarUrl = viewModel?.avatarUrl {
//            self.imageView?.loadImageUsingCacheWithURLString(avatarUrl.absoluteString, placeHolder: #imageLiteral(resourceName: "ic_warning_black_bc"), completion: { [unowned self] succes in
//                self.imageView?.applyCircleShape()
//            })
        }
    }
    
}
