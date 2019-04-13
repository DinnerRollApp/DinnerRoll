//
//  MHIconButton.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 8/12/18.
//  Copyright © 2018 Michael Hulet. All rights reserved.
//

import Foundation

@IBDesignable class MHIconButton: UIButton{
    @IBInspectable var padding: CGFloat = 0

    override func layoutSubviews() -> Void{
        super.layoutSubviews()

        guard let imageSize = imageView?.frame.size, let textSize = titleLabel?.frame.size else{
            return
        }

        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center

        let totalHeight = imageSize.height + textSize.height + padding

        imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageSize.height), left: 0, bottom: 0, right: 0)
        titleEdgeInsets = UIEdgeInsets(top: imageSize.height + padding, left: -imageSize.width - padding, bottom: 0, right: 0)
        contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
}
