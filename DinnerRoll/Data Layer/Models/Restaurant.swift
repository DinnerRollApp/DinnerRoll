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

class Restaurant: NSObject, MKAnnotation{
    let id: String
    let name: String
    var twitterUsername: String?
    var phone: String?
    var address: String?
    var crossStreet: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: String?
    let location: CLLocationCoordinate2D
    var categories = [Category]()
    var primaryCategory: Category?
    let verified: Bool
    var isOpen: Bool?
    var price: Int?

    init?(json: JSON){
        let location = json["location"]
        guard let id = json["id"].string, let name = json["name"].string, let latitude = location["lat"].double, let longitude = location["lng"].double, let categories = json["categories"].array, let verified = json["verified"].bool else{
            return nil
        }
        self.id = id
        self.name = name
        self.verified = verified
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        var main: Category? = nil
        for category in categories{
            guard let valid = Category(json: category) else{
                continue
            }
            if let primary = category["primary"].bool, primary{
                main = valid
            }
            self.categories.append(valid)
        }
        self.primaryCategory = main
        super.init()
        addData(from: json)
    }

    func addData(from json: JSON) -> Void{
        let location = json["location"]
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

    var coordinate: CLLocationCoordinate2D{
        get{
            return location
        }
    }
    var title: String?{
        get{
            return name
        }
    }
    var subtitle: String?{
        get{
            return address
        }
    }
 }
