//
//  CardView.swift
//  GDM
//
//  Created by Matt on 23.05.21.
//

import Foundation

import UIKit

@IBDesignable
///Make a regular view to a card view via IB
class CardView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 2

    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.5
    @IBInspectable var borderColor: UIColor = .clear
    @IBInspectable var borderWidth: Float = 0

    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)

        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
        layer.borderColor = self.borderColor.cgColor
        layer.borderWidth = CGFloat(self.borderWidth)
    }

}
