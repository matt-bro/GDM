//
//  ProfileCardViewModel.swift
//  GDM
//
//  Created by Matt on 26.05.21.
//

import Foundation

struct ProfileCardViewModel {
    //user login name
    let userHandle: String?
    //user real name
    let name: String?
    let followers: Int
    //followers formated with locale
    var followersString: String {
        return "\("Followers".ll) \(followers)"
    }
    let following: Int
    var followingString: String {
        return "\("Following".ll) \(following)"
    }
    //image url
    let avatarUrl: String?

}
