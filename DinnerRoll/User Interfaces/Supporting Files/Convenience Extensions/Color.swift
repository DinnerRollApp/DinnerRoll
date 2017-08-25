//
//  Color.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 8/23/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit

extension UIColor{
    var red: CGFloat{
        get{
            var r: CGFloat = 0
            getRed(&r, green: nil, blue: nil, alpha: nil)
            return r
        }
    }
    var green: CGFloat{
        get{
            var g: CGFloat = 0
            getRed(nil, green: &g, blue: nil, alpha: nil)
            return g
        }
    }
    var blue: CGFloat{
        get{
            var b: CGFloat = 0
            getRed(nil, green: nil, blue: &b, alpha: nil)
            return b
        }
    }
    var alpha: CGFloat{
        get{
            var a: CGFloat = 0
            getRed(nil, green: nil, blue: nil, alpha: &a)
            return a
        }
    }
    var hue: CGFloat{
        get{
            var h: CGFloat = 0
            getHue(&h, saturation: nil, brightness: nil, alpha: nil)
            return h
        }
    }
    var saturation: CGFloat{
        get{
            var s: CGFloat = 0
            getHue(nil, saturation: &s, brightness: nil, alpha: nil)
            return s
        }
    }
    var brightness: CGFloat{
        get{
            var b: CGFloat = 0
            getHue(nil, saturation: nil, brightness: &b, alpha: nil)
            return b
        }
    }
    var whiteness: CGFloat{
        get{
            var w: CGFloat = 0
            getWhite(&w, alpha: nil)
            return w
        }
    }
    func brighten(by percent: CGFloat) -> UIColor{
        return UIColor(hue: hue, saturation: saturation, brightness: brightness + (percent / 100), alpha: alpha)
    }
    func darken(by percent: CGFloat) -> UIColor{
        return brighten(by: -percent)
    }
    func lighten(by percent: CGFloat) -> UIColor{
        return UIColor(hue: hue, saturation: saturation - (percent / 100), brightness: brightness, alpha: alpha)
    }
}
