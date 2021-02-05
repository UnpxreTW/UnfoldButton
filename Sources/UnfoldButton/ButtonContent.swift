//
//  ButtonContent.swift
//  UnfoldButton
//
//  Created by UnpxreTW on 2021/02/05.
//  Copyright © 2021 UnpxreTW. All rights reserved.
//
import UIKit

public protocol ButtonContent: Hashable, CaseIterable {

    var contentImage: UIImage? { get }

    var contentIndex: Int { get }

    init(by stateIndex: Int)
}
