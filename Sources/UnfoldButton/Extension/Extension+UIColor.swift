//
//  Extension+UIColor.swift
//  UnfoldButton
//
//  Created by UnpxreTW on 2021/02/09.
//  Copyright © 2021 UnpxreTW. All rights reserved.
//
import UIKit.UIColor

extension UIColor {

    static var buttonColor: UIColor {
        if #available(iOS 13.0, *) {
            return label
        } else {
            return white
        }
    }

    static var hightlightColor: UIColor {
        if #available(iOS 13.0, *) {
            return label
        } else {
            return white
        }
    }
}
