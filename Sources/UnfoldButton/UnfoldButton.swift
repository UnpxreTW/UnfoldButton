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

public protocol UnfoldButtonAction: AnyObject {

    associatedtype `Type`: ButtonContent

    var selectAction: ((Type) -> Void)? { get }

    var setUseful: (([Type]) -> Void) { get }

    var closeAction: ((Bool) -> Void) { get }
}

public final class UnfoldButton<Type: ButtonContent>: UIViewController, UnfoldButtonAction {

    // MARK: Public Variable

    public weak var delegate: UnfoldButtonDelegate?

    public var frame: CGRect { view.frame }

    public var size: CGSize = .init(width: 55, height: 55)

    public lazy var selectAction: ((Type) -> Void)? = { [self] in
        selected = $0
        setConstraint()
        setAnimation()
    }

    public lazy var setUseful: (([Type]) -> Void) = { [self] in
        allSelection = $0
        resetAllButton()
        setConstraint()
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
    private var safeInset: CGFloat { view.safeAreaInsets.left }

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
        setConstraint()
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

    public override func viewSafeAreaInsetsDidChange() {
        setConstraint()
        setAnimation()
    }

    // MARK: Private Function

    @objc private func tapButton(_ sender: UIButton) {
        delegate?.tapped(isOpened ? selected : nil)
        setAnimation(to: !isOpened, select: sender.tag)
    }

    private func setAnimation(to open: Bool? = nil, select: Int? = nil) {
        let toOpen: Bool = open.or(isOpened)
        DispatchQueue.main.async { [self] in
            view.superview?.layoutIfNeeded()
            NSLayoutConstraint.deactivate(toOpen ? closeConstraints : openConstraints)
            if isOpened {
                select.isSome { selected = Type.init(by: $0) }
                setConstraint()
            }
            NSLayoutConstraint.activate(toOpen ? openConstraints : closeConstraints)
            let animator: UIViewPropertyAnimator = .init(duration: 0.5, dampingRatio: 1) {
                view.superview?.layoutIfNeeded()
                backgroundView?.frame = view.frame
                highlightView.alpha = toOpen ? 1 : 0
                buttons.forEach { $1.tintColor = toOpen && $0 == selected ? .hightlightColor : .buttonColor }
            }
            animator.addCompletion { if case .end = $0 { isOpened = toOpen } }
            animator.startAnimation()
        }
    }

    private func resetAllButton() {
        buttons.values.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        loadAllButton()
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

    private func setConstraint() {
        setOpenConstraint()
        setCloseConstraint()
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
                openConstraints.append(
                    button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: safeInset)
                )
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
                    ? lastButton.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -safeInset)
                    : button.leadingAnchor.constraint(equalTo: lastButton.trailingAnchor)
                )
            }
            if selection == selected { isLeading = false }
            lastButton = button
        }
        buttons[selected].isSome {
            closeConstraints.append(contentsOf: [
                $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: safeInset),
                view.trailingAnchor.constraint(equalTo: $0.trailingAnchor),
                highlightView.leadingAnchor.constraint(equalTo: $0.leadingAnchor)
            ])
        }
    }
}
