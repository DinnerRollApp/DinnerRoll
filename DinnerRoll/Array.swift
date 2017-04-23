//
//  Array.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 4/20/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import Foundation

extension Array{
    var randomIndex: Int{
        get{
            return count > 0 ? Int(arc4random_uniform(UInt32(count))) : NSNotFound
        }
    }
    var randomElement: Element{
        get{
            return self[randomIndex]
        }
    }
}
