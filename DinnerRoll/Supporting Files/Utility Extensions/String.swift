//
//  String.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 8/10/19.
//  Copyright © 2019 Michael Hulet. All rights reserved.
//

extension String{
    static func *(left: String, right: Int) -> String{
        return String(repeating: left, count: right)
    }
}
