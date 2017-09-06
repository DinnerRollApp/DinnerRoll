//
//  RestaurantCategory.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 8/4/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit
import SwiftyJSON
import QuadratTouch

struct Category{
    let name: String
    let pluralName: String
    let shortName: String
    let id: String
    private(set) var glyph: UIImage?
    private let glyphLocation: String

    init?(json: JSON){
        glyph = nil
        let iconKey = "icon"
        guard let name = json["name"].string, let plural = json["pluralName"].string, let short = json["shortName"].string, let identifier = json["id"].string, let prefix = json[iconKey]["prefix"].string, let suffix = json[iconKey]["suffix"].string else{
            return nil
        }
        self.name = name
        self.pluralName = plural
        self.shortName = short
        self.id = identifier
        self.glyphLocation = prefix + suffix
    }

    mutating func downloadGlyph(completion: () -> Void) -> Void{
        
    }

    static func getAllRestaurantCategories(completion: @escaping ([Category]) -> Void) -> Void{
        let task = QuadratTouch.Session.sharedSession().venues.categories{(result: Result) in
            // TODO: Convert JSON to [Category] and assign the results to the cache
            guard let response = result.response else{
                print("Failed to get list of categories")
                completion([])
                return
            }
            guard let all = JSON(response)["categories"].array else{
                print("Could not convert response to an array")
                completion([])
                return
            }
            func allSubcategories(in list: [JSON]) -> [Category]{
                var types = [Category]()
                for json in list{
                    guard let type = Category(json: json) else{
                        break
                    }
                    types.append(type)
                    if let subs = json["categories"].array{
                        types += allSubcategories(in: subs)
                    }
                }
                return types
            }
            var result = allSubcategories(in: all.filter({ (json: JSON) -> Bool in
                return json["id"] == "4d4b7105d754a06374d81259" || json["name"] == "Food"
            }))
            if result.count > 0{
                result.remove(at: 0) // We don't want the generic "Food" category to be included
            }
            completion(result)
        }
        task.start()
    }
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
