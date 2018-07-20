//
//  IBExtensions.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 7/30/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit
import TagListView

extension UIView{

    // MARK: - Corner Radius

    @IBInspectable var cornerRadius: CGFloat{
        get{
            return layer.cornerRadius
        }
        set{
            layer.cornerRadius = newValue
        }
    }

    // MARK: - Drop Shadow

    @IBInspectable var shadowColor: UIColor?{
        get{
            guard let color = layer.shadowColor else{
                return nil
            }
            return UIColor(cgColor: color)
        }
        set{
            layer.shadowColor = newValue?.cgColor
        }
    }

    @IBInspectable var shadowRadius: CGFloat{
        get{
            return layer.shadowRadius
        }
        set{
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable var shadowOpacity: Float{
        get{
            return layer.shadowOpacity
        }
        set{
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable var shadowOffset: CGSize{
        get{
            return layer.shadowOffset
        }
        set{
            layer.shadowOffset = newValue
        }
    }
}
