//
//  AppSession.swift
//  GDM
//
//  Created by Matt on 25.05.21.
//

import Foundation

protocol AppSessionProtocol {
    var currentUserId: Int { get set }
    var partnerId: Int { get set }
    var currentUserLogin: String {get set}
}

class AppSession: AppSessionProtocol {
    static let shared = AppSession()
    var currentUserId: Int = 18646247
    var currentUserLogin = "matt-bro"
    var partnerId: Int = -1
}
