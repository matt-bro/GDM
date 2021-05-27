//
//  UserListTVCNavigator.swift
//  GDM
//
//  Created by Matt on 24.05.21.
//

import UIKit

protocol UserListTVCNavigatable {
    func toChat(userId: Int, partnerId: Int, partnerName: String?)
    func toUserProfile()
}

final class UserListTVCNavigator: UserListTVCNavigatable {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toChat(userId: Int, partnerId: Int, partnerName: String?) {
        let vc = UIStoryboard.main.chatVC

        vc.title = "@\(partnerName ?? "")"

        let api = API()
        let db = Database.shared
        let session = AppSession.shared
        session.partnerId = partnerId


        let dependencies = ChatVCViewModel.Dependencies(api: api, db: db, session: session)
        vc.viewModel = ChatVCViewModel(dependencies: dependencies)

        navigationController.pushViewController(vc, animated: true)
    }

    func toUserProfile() {
        let vc = UIStoryboard.main.userTVC
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        let nav = UserTVCNavigator(navigationController: nc)

        let api = API.shared
        let db = Database.shared
        let session = AppSession.shared

        let dependencies = UserTVCViewModel.Dependencies(api: api, db: db, nav:nav, session: session)
        vc.viewModel = UserTVCViewModel(dependencies: dependencies)


        self.navigationController.present(nc, animated: true, completion: nil)
    }
}
