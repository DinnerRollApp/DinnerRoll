//
//  RestaurantCategory.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 8/4/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit

struct Category{
    let name: String
    let pluralName: String
    let shortName: String
    let id: String
    let glyph: UIImage?
}

extension Category: Equatable{
    static func ==(left: Category, right: Category) -> Bool{
        return left.id == right.id
    }
}

final class StorableCategory: NSObject{
    let contents: Category
    init(category: Category){
        contents = category
    }
}
