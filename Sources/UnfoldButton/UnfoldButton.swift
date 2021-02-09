//
//  UnfoldButton.swift
//  UnfoldButton
//
//  Created by UnpxreTW on 2021/02/05.
//  Copyright © 2021 UnpxreTW. All rights reserved.
//
import UIKit

public protocol UnfoldButtonDelegate: AnyObject {

    func tapped<Type: ButtonContent>(_ selected: Type?)
}

public final class UnfoldButton<Type: ButtonContent>: UIViewController {

    // MARK: Public Variable

    public weak var delegate: UnfoldButtonDelegate?

    public var size: CGSize = .init(width: 55, height: 55)

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
        setAnimation(to: .close)
    }

    // MARK: Private Variable

    private var isOpened: Bool = false
    private var allSelection: [Type] = []
    private var selected: Type = .init(by: 0)
    private var buttons: [Type: UIButton] = [:]
    private var closeConstraints: [NSLayoutConstraint] = []
    private var openConstraints: [NSLayoutConstraint] = []
    private var backgroundView: UIView?
    private lazy var highlightView: UIView = {
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        view.backgroundColor = .buttonColor
        return view
    }()

    // MARK: Lifecycle

    public init() {
        allSelection = Type.allCases.map { $0 }
        super.init(nibName: nil, bundle: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        DispatchQueue.main.async { [self] in
            view.addSubview(highlightView)
        }
        loadAllButton()
        setOpenConstraint()
        setCloseConstraint()
        DispatchQueue.main.async { [self] in
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: size.height),
                highlightView.widthAnchor.constraint(equalToConstant: size.width),
                highlightView.heightAnchor.constraint(equalToConstant: size.height),
                highlightView.topAnchor.constraint(equalTo: view.topAnchor)
            ])
            NSLayoutConstraint.activate(closeConstraints)
        }
    }

    public convenience init(with background: UIView) {
        self.init()
        backgroundView = background
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public Function

    // MARK: Private Function

    @objc private func tapButton(_ sender: UIButton) {
        setAnimation(to: !isOpened, select: sender.tag)
        delegate?.tapped(isOpened ? selected : nil)
    }

    private func setAnimation(to open: Bool? = nil, select: Int? = nil) {
        let toOpen: Bool = open.or(isOpened)
        DispatchQueue.main.async { [self] in
            view.superview?.layoutIfNeeded()
            NSLayoutConstraint.deactivate(toOpen ? closeConstraints : openConstraints)
            if !toOpen {
                select.isSome { selected = Type.init(by: $0) }
                setCloseConstraint()
                setOpenConstraint()
            }
            NSLayoutConstraint.activate(toOpen ? openConstraints : closeConstraints)
            isOpened = toOpen
            let animator: UIViewPropertyAnimator = .init(duration: 0.5, dampingRatio: 1) {
                view.superview?.layoutIfNeeded()
                backgroundView?.frame.size = view.frame.size
                highlightView.alpha = toOpen ? 1 : 0
                buttons.forEach { $1.tintColor = toOpen && $0 == selected ? .hightlightColor : .buttonColor }
            }
            animator.addCompletion { if case .end = $0 { isOpened = toOpen } }
            animator.startAnimation()
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
                    button.widthAnchor.constraint(equalToConstant: size.width),
                    button.heightAnchor.constraint(equalToConstant: size.height),
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
        lastButton.isSome { openConstraints.append(view.trailingAnchor.constraint(equalTo: $0.trailingAnchor)) }
        buttons[selected].isSome {
            openConstraints.append(highlightView.leadingAnchor.constraint(equalTo: $0.leadingAnchor))
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
                closeConstraints.append(isLeading
                    ? lastButton.trailingAnchor.constraint(equalTo: button.leadingAnchor)
                    : button.leadingAnchor.constraint(equalTo: lastButton.trailingAnchor)
                )
            }
            if selection == selected {
                closeConstraints.append(button.leadingAnchor.constraint(equalTo: view.leadingAnchor))
                closeConstraints.append(view.trailingAnchor.constraint(equalTo: button.trailingAnchor))
                closeConstraints.append(highlightView.leadingAnchor.constraint(equalTo: button.leadingAnchor))
                isLeading = false
            }
            lastButton = button
        }
    }
}
