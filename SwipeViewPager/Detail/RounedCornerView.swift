//
//  RounedCornerView.swift
//  SwipeViewPager
//
//  Created by jylee-mac on 2021/05/21.
//

import UIKit

@IBDesignable
class RounedCornerView: UIView {

    // if cornerRadius variable is set/changed, change the corner radius of the UIView
        @IBInspectable var cornerRadius: CGFloat = 0 {
            didSet {
                layer.cornerRadius = cornerRadius
                layer.masksToBounds = cornerRadius > 0
            }
        }
        
        @IBInspectable var borderWidth: CGFloat = 0 {
            didSet {
                layer.borderWidth = borderWidth
            }
        }
        
        @IBInspectable var borderColor: UIColor? {
            didSet {
                layer.borderColor = borderColor?.cgColor
            }
        }
}
