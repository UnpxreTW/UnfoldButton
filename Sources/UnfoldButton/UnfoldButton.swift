//
//  UnfoldButton.swift
//  UnfoldButton
//
//  Created by UnpxreTW on 2021/02/05.
//  Copyright © 2021 UnpxreTW. All rights reserved.
//
import UIKit

private extension UIColor {

    static var buttonColor: UIColor {
        if #available(iOS 13.0, *) {
            return label
        } else {
            return white
        }
    }
}

public protocol UnfoldButtonDelegate: AnyObject {

    func tapped<Type: ButtonContent>(_ selected: Type?)
}

public final class UnfoldButton<Type: ButtonContent>: UIViewController {

    // MARK: Public Variable

    public weak var delegate: UnfoldButtonDelegate?

    public var buttonSize: CGFloat = 55

    public lazy var selectAction: ((Type) -> Void)? = { [self] in
        selected = $0
        setOpenConstraint()
        setCloseConstraint()
    }

    public lazy var setUseful: (([Type]) -> Void) = { [self] in
        allSelection = $0
        cleanAllButton()
        loadAllButton()
        setOpenConstraint()
    }

    public lazy var closeAction: ((Bool) -> Void) = { [self] _ in
        guard isOpened else { return }
        DispatchQueue.main.async {
            view.superview?.layoutIfNeeded()
            NSLayoutConstraint.deactivate(openConstraints)
            NSLayoutConstraint.activate(closeConstraints)
            UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
                view.superview?.layoutIfNeeded()
            }.startAnimation()
        }
        isOpened = false
    }

    // MARK: Private Variable

    private var isOpened: Bool = false
    private var allSelection: [Type] = []
    private var selected: Type = .init(by: 0)
    private var buttons: [Type: UIButton] = [:]
    private var closeConstraints: [NSLayoutConstraint] = []
    private var openConstraints: [NSLayoutConstraint] = []
    private var backgroundView: UIView?

    // MARK: Lifecycle

    public init() {
        allSelection = Type.allCases.map { $0 }
        super.init(nibName: nil, bundle: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        loadAllButton()
        setOpenConstraint()
        setCloseConstraint()
        DispatchQueue.main.async { [self] in
            NSLayoutConstraint.activate([view.heightAnchor.constraint(equalToConstant: buttonSize)])
            NSLayoutConstraint.activate(closeConstraints)
        }
    }

    public convenience init(with background: UIView) {
        self.init()
        backgroundView = background
        DispatchQueue.main.async { [self] in
            NSLayoutConstraint.activate([
                background.widthAnchor.constraint(equalTo: view.widthAnchor)
            ])
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print(view.frame)
        backgroundView?.frame = view.frame
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(view.frame)
        backgroundView?.frame = view.frame
    }

    // MARK: Public Function

    // MARK: Private Function

    @objc private func tapButton(_ sender: UIButton) {
        DispatchQueue.main.async { [self] in
            view.superview?.layoutIfNeeded()
            NSLayoutConstraint.deactivate(isOpened ? openConstraints : closeConstraints)
            if isOpened {
                selected = Type.init(by: sender.tag)
                setCloseConstraint()
            }
            delegate?.tapped(isOpened ? selected : nil)
            NSLayoutConstraint.activate(isOpened ? closeConstraints : openConstraints)
            isOpened.toggle()
            UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
                view.superview?.layoutIfNeeded()
            }.startAnimation()
        }
    }

    private func cleanAllButton() {
        buttons.values.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
    }

    private func loadAllButton() {
        for selection in allSelection {
            let button: UIButton = .init()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = .buttonColor
            button.setImage(selection.contentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.tag = selection.contentIndex
            button.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
            DispatchQueue.main.async { [self] in
                view.addSubview(button)
                NSLayoutConstraint.activate([
                    button.widthAnchor.constraint(equalToConstant: buttonSize),
                    button.heightAnchor.constraint(equalToConstant: buttonSize),
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
            openConstraints.append(view.trailingAnchor.constraint(equalTo: lastButton.trailingAnchor))
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
                if isLeading {
                    closeConstraints.append(lastButton.trailingAnchor.constraint(equalTo: button.leadingAnchor))
                } else {
                    closeConstraints.append(button.leadingAnchor.constraint(equalTo: lastButton.trailingAnchor))
                }
            }
            if selection == selected {
                closeConstraints.append(button.leadingAnchor.constraint(equalTo: view.leadingAnchor))
                closeConstraints.append(view.trailingAnchor.constraint(equalTo: button.trailingAnchor))
                isLeading = false
            }
            lastButton = button
        }
    }
}
