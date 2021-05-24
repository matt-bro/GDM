//
//  ViewModelType.swift
//  GDM
//
//  Created by Matt on 24.05.21.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
