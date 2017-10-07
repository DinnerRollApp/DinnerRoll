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
import RealmSwift

@objcMembers class Category: RealmSwift.Object{
    dynamic var name = String()
    dynamic var pluralName = String()
    dynamic var shortName = String()
    dynamic var id = String()

    convenience init?(json: JSON){

        guard let _ = json["name"].string, let _ = json["pluralName"].string, let _ = json["shortName"].string, let _ = json["id"].string, let dictionary = json.dictionaryObject else{
            return nil
        }
        self.init(value: dictionary)
    }

    override static func primaryKey() -> String?{
        return "id"
    }

    static func getAllRestaurantCategories(completion: @escaping ([Category]) -> Void) -> Void{
        let lastCacheDateKey = "lastCategoryCacheDate"
        func network(completion: @escaping ([Category]) -> Void, writeToCache: Bool) -> Void{
            let task = QuadratTouch.Session.sharedSession().venues.categories{(result: QuadratTouch.Result) in
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
                var results = allSubcategories(in: all.filter({ (json: JSON) -> Bool in
                    return json["id"] == "4d4b7105d754a06374d81259" || json["name"] == "Food"
                }))
                if results.count > 0{
                    results.remove(at: 0) // We don't want the generic "Food" category to be included
                }
                if let realm = try? Realm(), writeToCache{
                    do{
                        try realm.write{
                            realm.add(results, update: true)
                            realm.delete(realm.objects(self).filter("NOT id IN %@", results.map({ (category: Category) -> String in
                                return category.id
                            })))
                        }
                        UserDefaults.standard.set(Date(), forKey: lastCacheDateKey)
                    }
                    // We're out of space, just don't cache anything
                    catch _{}
                }
                completion(results)
            }
            task.start()
        }
        do{
            let realm = try Realm()
            if let lastCacheUpdate = UserDefaults.standard.value(forKey: lastCacheDateKey) as? Date{
                let cacheResults = realm.objects(self)
                guard cacheResults.isEmpty || lastCacheUpdate.timeIntervalSinceNow < -604_800 else{ // Make sure there's data in the cache and it isn't stale. There are 604,800 seconds in a week
                    completion(cacheResults.array)
                    return
                }
            }
        }
        catch _{
            // Disk is out of space (or you need to write a migration if you changed the data model), just download all the categories and return
            network(completion: completion, writeToCache: false)
            return
        }
        // Realm objects are not thread-safe, so we have to capture the current thread and re-fetch the results on it
        @objc class ClosureWrapper: NSObject{
            let closure: () -> Void
            let thread: Thread
            init(thread: Thread, closure: @escaping () -> Void){
                self.thread = thread
                self.closure = closure
            }
            @objc private func runClosure() -> Void{
                closure()
            }
            func execute() -> Void{
                perform(#selector(runClosure), on: thread, with: nil, waitUntilDone: true)
            }
        }
        let loopbackClosure = ClosureWrapper(thread: Thread.current) {
            getAllRestaurantCategories(completion: completion)
        }
        network(completion: {(categories: [Category]) in
            loopbackClosure.execute()
        }, writeToCache: true)
    }
}
