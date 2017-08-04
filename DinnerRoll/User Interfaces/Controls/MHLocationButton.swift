//
//  MHLocationButton.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 7/30/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit

@IBDesignable class MHLocationButton: UIButton{
    enum Action{
        case center
        case follow
    }

    var currentAction: Action = .center{
        didSet{
            let newImage: UIImage
            switch currentAction{
                case .center:
                    newImage = #imageLiteral(resourceName: "Location Indicators/unfilled")
                case .follow:
                    newImage = #imageLiteral(resourceName: "Location Indicators/filled")
            }
            setImage(newImage, for: .normal)
        }
    }
}
