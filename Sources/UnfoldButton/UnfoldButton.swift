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

    public lazy var selectAction: ((Type) -> Void)? = { self.selected = $0 }

    public lazy var setUseful: (([Type]) -> Void) = { [self] in
        allSelection = $0
        cleanAllButton()
        loadAllButton()
        setOpenConstraint()
    }

    public lazy var closeAction: (() -> Void) = {
        DispatchQueue.main.async { [self] in
            view.layoutIfNeeded()
            // setConstraint(to: false)
            UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) { view.layoutIfNeeded() }.startAnimation()
        }
    }

    // MARK: Private Variable

    private var isOpened: Bool = false
    private var allSelection: [Type] = []
    private var selected: Type = .init(by: 0)
    private var buttons: [Type: UIButton] = [:]
    // private lazy var closeAnchor: NSLayoutConstraint = view.widthAnchor.constraint(equalToConstant: defaultSize)
    // private lazy var openAnchor: NSLayoutConstraint = view.widthAnchor.constraint(equalToConstant: defaultSize)
    // private var firstButtonAnchor: NSLayoutConstraint?

    private var closeConstraints: [NSLayoutConstraint] = []
    private var openConstraints: [NSLayoutConstraint] = []

    // MARK: Lifecycle

    public init() {
        allSelection = Type.allCases.map { $0 }
        super.init(nibName: nil, bundle: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        loadAllButton()
        setOpenConstraint()
        setCloseConstraint()
        DispatchQueue.main.async { [self] in
            NSLayoutConstraint.activate([view.heightAnchor.constraint(equalToConstant: defaultSize)])
            NSLayoutConstraint.activate(closeConstraints)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public Function

    // MARK: Private Function

    private func cleanAllButton() {
        buttons.values.forEach { $0.removeFromSuperview() }
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
                NSLayoutConstraint.activate([
                    button.widthAnchor.constraint(equalToConstant: defaultSize),
                    button.heightAnchor.constraint(equalToConstant: defaultSize),
                    button.topAnchor.constraint(equalTo: view.topAnchor)
                ])
            }
            buttons.updateValue(button, forKey: selection)
        }
    }

    private func setOpenConstraint() {
        NSLayoutConstraint.deactivate(openConstraints)
        openConstraints.removeAll()
        var lastButton: UIButton?
        for selection in allSelection {
            guard let button = buttons[selection] else { continue }
            if let lastButton = lastButton {
                openConstraints.append(button.leadingAnchor.constraint(equalTo: lastButton.trailingAnchor))
            } else {
                openConstraints.append(button.leadingAnchor.constraint(equalTo: view.leadingAnchor))
            }
            lastButton = button
        }
        if let lastButton = lastButton {
            openConstraints.append(view.leadingAnchor.constraint(equalTo: lastButton.trailingAnchor))
        }
    }

    private func setCloseConstraint() {
        NSLayoutConstraint.deactivate(closeConstraints)
        closeConstraints.removeAll()
        var lastButton: UIButton?
        var isLeading: Bool = true
        for selection in allSelection {
            guard let button = buttons[selection] else { continue }
            if let lastButton = lastButton {
                if selection == selected {
                    closeConstraints.append(button.leadingAnchor.constraint(equalTo: view.leadingAnchor))
                    closeConstraints.append(view.trailingAnchor.constraint(equalTo: button.trailingAnchor))
                    isLeading = false
                } else {
                    if isLeading {
                        closeConstraints.append(lastButton.trailingAnchor.constraint(equalTo: button.leadingAnchor))
                    } else {
                        closeConstraints.append(button.leadingAnchor.constraint(equalTo: lastButton.trailingAnchor))
                    }
                }
            }
            lastButton = button
        }
    }
}
