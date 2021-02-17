//
//  ButtonContent.swift
//  UnfoldButton
//
//  Created by UnpxreTW on 2021/02/05.
//  Copyright © 2021 UnpxreTW. All rights reserved.
//
import UIKit.UIImage

public protocol ButtonContent: Hashable, CaseIterable, Comparable {

    var contentImage: UIImage? { get }

    var contentIndex: Int { get }

    init(by stateIndex: Int)
}
