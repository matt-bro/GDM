//
//  UITextField+Custom.swift
//  GDM
//
//  Created by Matt on 23.05.21.
//

import UIKit
import Combine

extension UITextField {
    //Publisher for textfield
    func textPublisher() -> AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { ($0.object as? UITextField)?.text  ?? "" }
            .eraseToAnyPublisher()
    }
  }
