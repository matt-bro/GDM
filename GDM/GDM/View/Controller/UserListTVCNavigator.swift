//
//  UserListTVCNavigator.swift
//  GDM
//
//  Created by Matt on 24.05.21.
//

import UIKit

protocol UserListTVCNavigatable {
    func toChat(userId: Int, parnterId: Int)
}

final class UserListTVCNavigator: UserListTVCNavigatable {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toChat(userId: Int, parnterId: Int) {
        let vc = UIStoryboard.main.chatVC

        let dependencies = ChatVCViewModel.Dependencies(
            api: MockAPI(),
            db: Database.shared
        )
        vc.viewModel = ChatVCViewModel(dependencies: dependencies)

        navigationController.pushViewController(vc, animated: true)
    }
}
