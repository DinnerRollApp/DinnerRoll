//
//  MHFilterView.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 8/19/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit
import TagListView

class MHFilterView: UIView{
    @IBOutlet weak var searchBar: MHFilterEntryField!
    @IBOutlet weak var tagView: TagListView!
}

// MARK: - Text Input Subclasses

class MHFilterEntryField: SearchTextField{
    // MARK: Placeholder Appearance Manipulation
    override var placeholder: String?{
        didSet{
            updatePlaceholder(with: placeholder)
        }
    }

    override func awakeFromNib() -> Void{
        super.awakeFromNib()
        updatePlaceholder(with: placeholder)
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    private func updatePlaceholder(with: String?) -> Void{
        guard let new = with else{
            attributedPlaceholder = nil
            return
        }
        attributedPlaceholder = NSAttributedString(string: new, attributes: [NSForegroundColorAttributeName: tintColor.withAlphaComponent(0.5).lighten(by: 50)])
    }

    // MARK: Text Location Manipulation

    private let textInset: CGFloat = 35

    private func rect(for original: CGRect) -> CGRect{
        let inset = original.insetBy(dx: textInset, dy: 0)
        return CGRect(x: inset.origin.x, y: original.origin.y, width: inset.width + textInset, height: original.size.height)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect{
        return rect(for: super.textRect(forBounds: bounds))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect{
        return rect(for: super.editingRect(forBounds: bounds))
    }

    // MARK: Keyboard Appearance Patches

    private var lastBecameFirstResponder: Date? = nil
    override var canResignFirstResponder: Bool{
        get{
            guard let last = lastBecameFirstResponder else{
                return true
            }
            return last.timeIntervalSinceNow < -0.5
        }
    }


    override func becomeFirstResponder() -> Bool{
        lastBecameFirstResponder = Date()
        return super.becomeFirstResponder()
    }
}
