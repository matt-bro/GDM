//
//  UIStoryboard+Custom.swift
//  GDM
//
//  Created by Matt on 24.05.21.
//

import Foundation

import UIKit

extension UIStoryboard {
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}

extension UIStoryboard {
    var userListTVC: UserListTVC {
        let id = "UserListTVC"
        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: id) as? UserListTVC else {
            fatalError(couldNotFindSB(id: id, sbName: UIStoryboard.main.description))
        }
        return vc
    }

    var chatVC: ChatVC {
        let id = "ChatVC"
        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: id) as? ChatVC else {
            fatalError(couldNotFindSB(id: id, sbName: UIStoryboard.main.description))
        }
        return vc
    }

    private func couldNotFindSB(id:String, sbName: String) -> String {
        "Couldn't find \(id) in storyboard named \(sbName)"
    }
}
