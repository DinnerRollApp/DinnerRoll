//
//  RestaurantCategory.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 8/4/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

struct Category{
    let name: String
    let pluralName: String
    let shortName: String
    let id: String

    init?(json: JSON){
        guard let name = json["name"].string, let plural = json["pluralName"].string, let short = json["shortName"].string, let id = json["id"].string else{
            return nil
        }
        self.name = name
        self.pluralName = plural
        self.shortName = short
        self.id = id
    }

    static func getAllRestaurantCategories(completion: @escaping ([Category]) -> Void) -> Void{
        request(API.categories).responseSwiftyJSON{(response: DataResponse<JSON>) in
            guard let result = response.value, let data = result.array else{
                return
            }
            completion(data.map({(category: JSON) -> Category in
                return Category(json: category)!
            }))
        }
    }
}
