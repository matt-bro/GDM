//
//  Date+Custom.swift
//  GDM
//
//  Created by Matt on 23.05.21.
//

import Foundation

extension Date {

    ///Standard formatter for our date in locale long format
    var string: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        let dateString = formatter.string(from: self)
        return dateString
    }
}
