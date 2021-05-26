//
//  EmptyView.swift
//  GDM
//
//  Created by Matt on 25.05.21.
//

import UIKit


class EmptyView: UIView {

    var titleLabel: UILabel?
    var subTitleLabel: UILabel?
    var logo: UIImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupView() {

        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.text = ""
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .gray
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel = titleLabel
        self.addSubview(titleLabel)

        let subTitleLabel = UILabel(frame: CGRect.zero)
        subTitleLabel.text = ""
        subTitleLabel.numberOfLines = 0
        subTitleLabel.textColor = .gray
        subTitleLabel.textAlignment = .center
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subTitleLabel = subTitleLabel
        self.addSubview(subTitleLabel)

        let logo = UIImageView()
        logo.translatesAutoresizingMaskIntoConstraints = false
        self.logo = logo
        self.addSubview(logo)

        let constraints = [
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -15),
            subTitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subTitleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -15),
            logo.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            logo.widthAnchor.constraint(equalToConstant: 150),
            logo.heightAnchor.constraint(equalTo: logo.widthAnchor),
            logo.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 5),
        ]
        NSLayoutConstraint.activate(constraints)
    }

}


extension EmptyView {

    static func noMessages() -> UIView {
        let emptyView = EmptyView(frame: .zero)
        emptyView.titleLabel?.text = "There are no messages here yet".ll
        emptyView.subTitleLabel?.text = "Be the first one to write a message!".ll
        emptyView.logo?.image = #imageLiteral(resourceName: "empty 2-fmc")
        return emptyView
    }

    static func noFollowers() -> UIView {
        let emptyView = EmptyView(frame: .zero)
        emptyView.titleLabel?.text = "There are no followers here yet :(".ll
        emptyView.subTitleLabel?.text = "Maybe try to refresh?".ll
        emptyView.logo?.image = #imageLiteral(resourceName: "no-wifi")
        return emptyView
    }

    static func empty() -> UIView {
        let emptyView = EmptyView(frame: .zero)
        emptyView.titleLabel?.text = "There are no files here yet".ll
        emptyView.subTitleLabel?.text = "You might not have sufficent permissions. Please contact oneapp@fmc-ag.com.".ll
        emptyView.logo?.image = #imageLiteral(resourceName: "empty 2-fmc")
        return emptyView
    }
}
