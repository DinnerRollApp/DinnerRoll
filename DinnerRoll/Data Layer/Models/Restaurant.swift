//
//  Restaurant.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 9/26/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import Foundation
import SwiftyJSON
import MapKit

struct Restaurant{
    let id: String
    let name: String
    let twitterUsername: String?
    let phone: String?
    let address: String?
    let crossStreet: String?
    let city: String?
    let state: String?
    let postalCode: String?
    let country: String?
    let location: CLLocationCoordinate2D
    let categories: [Category]
    let primaryCategory: Category?
    let verified: Bool
    let isOpen: Bool?
    let price: Int?

    init?(json: JSON){
        let location = json["location"]
        guard let id = json["id"].string, let name = json["name"].string, let latitude = location["lat"].double, let longitude = location["lng"].double, let categories = json["categories"].array, let verified = json["verified"].bool else{
            return nil
        }
        self.id = id
        self.name = name
        self.location = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        self.verified = verified
        var types = [Category]()
        var main: Category? = nil
        for category in categories{
            guard let valid = Category(json: category) else{
                continue
            }
            if let primary = category["primary"].bool, primary{
                main = valid
            }
            types.append(valid)
        }
        self.primaryCategory = main
        self.categories = types
        let contactInfo = json["contact"]
        self.twitterUsername = contactInfo["twitter"].string
        self.phone = contactInfo["phone"].string
        self.address = location["address"].string
        self.crossStreet = location["crossStreet"].string
        self.city = location["city"].string
        self.state = location["state"].string
        self.postalCode = location["postalCode"].string
        self.country = location["country"].string
        self.isOpen = json["hours"]["isOpen"].bool
        self.price = json["price"]["tier"].int
    }
}

class RestaurantPin: NSObject, MKAnnotation{
    let restaurant: Restaurant
    var coordinate: CLLocationCoordinate2D{
        get{
            return restaurant.location
        }
    }
    init(restaurant: Restaurant){
        self.restaurant = restaurant
    }
}
