//
//  CompactUserCellViewModel.swift
//  GDM
//
//  Created by Matt on 24.05.21.
//

import UIKit

final class CompactUserCellViewModel {
    //main title
    var title: String?
    //user image
    var avatarUrl: URL?

    init(title: String?, avatarUrl: String?) {
        self.title = title

        if let avatarUrl = avatarUrl {
            self.avatarUrl = URL(string: avatarUrl)
        }
    }
}
