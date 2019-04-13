//
//  ForceTouchGestureRecognizer.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 7/28/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

/// Recognizes a force press on devices that support it, but falls back to a backup recognizer if it's not supported
class ForceTouchGestureRecognizer: UIGestureRecognizer{
    /// The minimum force required to trigger the gesture recognizer
    var minimumForce: CGFloat = 4
    /// This gesture recognizer that will be honored if the device doesn't support 3D Touch. The default is a `UILongPressGestureRecognizer` configured to this recognizer's `target` and `action`
    var fallbackRecognizer: UIGestureRecognizer?{
        didSet{
            fallbackRecognizer?.delegate = delegate
            fallbackRecognizer?.isEnabled = isEnabled
        }
    }
    /// The current force of the touch being analyzed by the gesture recognizer
    private(set) var force: CGFloat = 0
    /// The maximum possible force of the touch being analyzed by the gesture recognizer
    private(set) var maximumPossibleForce: CGFloat = 0

    override var delegate: UIGestureRecognizerDelegate?{
        didSet{
            fallbackRecognizer?.delegate = delegate
        }
    }

    override var isEnabled: Bool{
        didSet{
            fallbackRecognizer?.isEnabled = isEnabled
        }
    }

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        fallbackRecognizer = UILongPressGestureRecognizer(target: target, action: action)
        addObserver(self, forKeyPath: #keyPath(view), options: [.old, .new], context: nil)
    }

    deinit{
        removeObserver(self, forKeyPath: #keyPath(view))
    }

    func update(traitCollection: UITraitCollection) -> Void{
        switch traitCollection.forceTouchCapability{
            case .available:
                isEnabled = true
                fallbackRecognizer?.isEnabled = false
            case .unavailable:
                isEnabled = false
                fallbackRecognizer?.isEnabled = true
            case .unknown:
                fallthrough
            @unknown default:
                return
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) -> Void{
        super.touchesBegan(touches, with: event)
        analyzeForce(for: touches, shouldEnd: false)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) -> Void{
        super.touchesMoved(touches, with: event)
        analyzeForce(for: touches, shouldEnd: false)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) -> Void{
        super.touchesEnded(touches, with: event)
        analyzeForce(for: touches, shouldEnd: true)
    }

    private func analyzeForce(for touches: Set<UITouch>, shouldEnd: Bool) -> Void{
        guard let touch = touches.first else{
            state = .failed
            return
        }

        maximumPossibleForce = touch.maximumPossibleForce
        force = touch.force

        if force >= minimumForce && state == .possible && !shouldEnd{
            state = .began
        }
        else if state == .began && !shouldEnd{
            state = .changed
        }
        else if shouldEnd && state == .possible{
            state = .failed
        }
        else if shouldEnd && (state == .began || state == .changed){
            state = .ended
        }
    }

    override func reset() -> Void{
        super.reset()
        force = 0
        maximumPossibleForce = 0
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) -> Void{
        super.touchesCancelled(touches, with: event)
        state = .cancelled
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) -> Void{
        guard let diff = change else{
            return
        }

        guard let new = diff[.newKey] as? UIView else{
            if let fallback = fallbackRecognizer{
                (diff[.oldKey]! as! UIView).removeGestureRecognizer(fallback)
            }
            return
        }

        update(traitCollection: new.traitCollection)
        guard let fallback = fallbackRecognizer else{
            return
        }
        new.addGestureRecognizer(fallback)
    }
}
