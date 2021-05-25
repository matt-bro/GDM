//
//  CompactUserCellViewModel.swift
//  GDM
//
//  Created by Matt on 24.05.21.
//

import UIKit

final class CompactUserCellViewModel {
    var id = -1
    //main title
    var title: String?
    //user image
    var avatarUrl: URL?

    init(id: Int, title: String?, avatarUrl: String?) {
        self.id = id
        self.title = title

        if let avatarUrl = avatarUrl {
            self.avatarUrl = URL(string: avatarUrl)
        }
    }
}
