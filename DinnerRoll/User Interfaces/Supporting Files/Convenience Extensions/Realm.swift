//
//  Realm.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 10/6/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import Foundation
import RealmSwift

extension RealmCollection{
    var array: [Element]{
        get{
            return map({(object: Element) -> Element in
                return object
            })
        }
    }
}
