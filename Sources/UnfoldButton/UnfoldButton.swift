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

    public var selectAction: ((Type) -> Void)?

    public lazy var setUseful: (([Type]) -> Void) = { [self] in
        allSelection = $0
        cleanAllButton()
        loadAllButton()
    }

    // MARK: Private Variable

    private var allSelection: [Type] = []
    private var selected: Type = .init(by: 0)
    private var buttons: [UIButton] = []
    private lazy var closeAnchor: NSLayoutConstraint = view.widthAnchor.constraint(equalToConstant: defaultSize)

    // MARK: Lifecycle

    public init() {
        allSelection = Type.allCases.map { $0 }
        super.init(nibName: nil, bundle: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        DispatchQueue.main.async { [self] in
            NSLayoutConstraint.activate([view.heightAnchor.constraint(equalToConstant: defaultSize), closeAnchor])
        }
        loadAllButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public Function

    // MARK: Private Function

    private func cleanAllButton() {
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
    }

    private func loadAllButton() {
        for selection in allSelection {
            let button: UIButton = .init()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setImage(selection.contentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.tag = selection.contentIndex
            DispatchQueue.main.async { [self] in
                view.addSubview(button)
                button.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                if let leadingButton = buttons.last {
                    button.leadingAnchor.constraint(equalTo: leadingButton.trailingAnchor).isActive = true
                } else {
                    button.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                }
            }
            buttons.append(button)
        }
    }
}
