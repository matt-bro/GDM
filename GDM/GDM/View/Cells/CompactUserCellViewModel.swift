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
    var subtitle: String?
    var date: String?
    var hasSubtitle: Bool {
        subtitle?.isEmpty ?? false
    }

    init(id: Int, title: String?, avatarUrl: String?, subtitle: String?, date: String?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.date = date

        if let avatarUrl = avatarUrl {
            self.avatarUrl = URL(string: avatarUrl)
        }
    }
}
