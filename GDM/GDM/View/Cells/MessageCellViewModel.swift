//
//  MessageCellViewModel.swift
//  GDM
//
//  Created by Matt on 25.05.21.
//

import UIKit

struct MessageCellViewModel {
    var id: Int = -1
    //tells us if the message was sent by us
    var isMe: Bool = true
    let message: String?
    let date: Date?
}
