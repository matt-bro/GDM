//
//  ProfileCardViewModel.swift
//  GDM
//
//  Created by Matt on 26.05.21.
//

import Foundation

struct ProfileCardViewModel {
    let userHandle: String?
    let name: String?
    let followers: Int
    var followersString: String {
        return "\("Followers".ll) \(followers)"
    }
    let following: Int
    var followingString: String {
        return "\("Following".ll) \(following)"
    }

    let avatarUrl: String?

}
