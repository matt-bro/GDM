//
//  UserListTVCNavigator.swift
//  GDM
//
//  Created by Matt on 24.05.21.
//

import UIKit

protocol UserListTVCNavigatable {
    func toChat(userId: Int, partnerId: Int)
}

final class UserListTVCNavigator: UserListTVCNavigatable {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toChat(userId: Int, partnerId: Int) {
        let vc = UIStoryboard.main.chatVC

        let api = MockAPI()
        let db = Database.shared
        let session = AppSession.shared
        session.partnerId = partnerId


        let dependencies = ChatVCViewModel.Dependencies(api: api, db: db, session: session)
        vc.viewModel = ChatVCViewModel(dependencies: dependencies)

        navigationController.pushViewController(vc, animated: true)
    }
}
