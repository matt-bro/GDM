//
//  UserTVCNavigator.swift
//  GDM
//
//  Created by Matt on 26.05.21.
//

import UIKit

final class UserTVCNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func done() {
        self.navigationController.dismiss(animated: true)
    }
}
