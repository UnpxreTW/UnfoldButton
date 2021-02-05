//
//  UnfoldButton.swift
//  UnfoldButton
//
//  Created by UnpxreTW on 2021/02/05.
//  Copyright © 2021 UnpxreTW. All rights reserved.
//
import UIKit

public final class UnfoldButton<Type: ButtonContent>: UIViewController {

    // MARK: Public Variable

    public var defaultSize: CGFloat = 55

    public var closeAction: (() -> Void) = {}

    public var select: ((Type) -> Void)?

    // MARK: Private Variable

    private var selected: Type = .init(by: 0)
    private var buttons: [UIButton] = []

    // MARK: Lifecycle

    public init() {
        super.init(nibName: nil, bundle: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public Function

    // MARK: Private Function

    private func loadAllButton() {

    }
}
