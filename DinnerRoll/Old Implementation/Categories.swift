//
//  Categories.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 7/12/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import SwiftyJSON
import QuadratTouch
import Security

func updateCategories() -> Void{
    let cache = URL(fileURLWithPath: "Categories.plist", relativeTo: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]))
    if !FileManager.default.fileExists(atPath: cache.path){
        FileManager.default.createFile(atPath: cache.path, contents: nil, attributes: nil)
        //print("Does not exist")
    }
    else{
        //print("Exists")
    }
    //print(cache.path)
    func refresh() -> Void{
        let task = QuadratTouch.Session.sharedSession().venues.categories({ (result: QuadratTouch.Result) in
            guard let data = result.response else{
                return
            }
            let categories = JSON(data)["categories"].array!
            let restaurants = categories.filter({ (category: JSON) -> Bool in
                return category["name"].string! == "Food"
            })
            print(restaurants)
        })
        task.start()
    }
}
