//
//  ObjectAssociation.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 7/27/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import Darwin

final class ObjectAssociation<AssociatedObject>{
    private let policy: objc_AssociationPolicy

    init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC){
        self.policy = policy
    }

    subscript(index: Any) -> AssociatedObject?{
        get{
            return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as? AssociatedObject
        }
        set{
            objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy)
        }
    }
}
