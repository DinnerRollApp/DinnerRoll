//
//  API.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 1/2/18.
//  Copyright © 2018 Michael Hulet. All rights reserved.
//

import Foundation
import Alamofire

private let secrets: [String: Any]? = {
    guard let file = Bundle.main.url(forResource: "APIKeys", withExtension: "plist") else{
        return nil
    }
    return NSDictionary(contentsOf: file) as? [String: Any]
}()

enum API: URLRequestConvertible{
    case categories
    case random(options: RandomOptions)

    struct RandomOptions{
        let location: CLLocationCoordinate2D
        let radius: CLLocationDistance
        let openNow: Bool
        let price: IndexSet
        let categories: [Category]
        let filters: [String]

        fileprivate var query: [URLQueryItem]{
            get{
                var items = [URLQueryItem(name: "latitude", value: String(location.latitude)), URLQueryItem(name: "longitude", value: String(location.longitude)), URLQueryItem(name: "radius", value: String(radius))]
                if openNow{
                    items.append(URLQueryItem(name: "openNow", value: "true"))
                }
                if !price.isEmpty{
                    items.append(URLQueryItem(name: "price", value: [Int](price).map({(value: Int) -> String in
                        return String(value)
                    }).joined(separator: ",")))
                }
                if !categories.isEmpty{
                    items.append(URLQueryItem(name: "categories", value: categories.map({(category: Category) -> String in
                        return category.id
                    }).joined(separator: ",")))
                }
                if !filters.isEmpty{
                    items.append(URLQueryItem(name: "search", value: filters.joined(separator: " ").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)))
                }
                return items
            }
        }

        // This exists to set default values on initialization without the defaults being mandatory
        init(location: CLLocationCoordinate2D, radius: CLLocationDistance, openNow: Bool, price: IndexSet = [], categories: [Category] = [], filters: [String] = []){
            self.location = location
            self.radius = radius
            self.openNow = openNow
            self.categories = categories
            self.filters = filters
            self.price = IndexSet(1...4).intersection(price)
        }
    }

    enum QueryError: Error{
        case secretFileNotFound
        case keyNotFound(key: String)
        case badURL
    }

    func asURLRequest() throws -> URLRequest{
        guard let base = URL(string: "https://api.dinnerroll.hulet.tech") else{
            throw QueryError.badURL
        }
        var components = URLComponents()
        components.queryItems = []
        guard let required = secrets else{
            throw QueryError.secretFileNotFound
        }
        let secretKey = "secret"
        guard let secret = required[secretKey] as? String else{
            throw QueryError.keyNotFound(key: secretKey)
        }
        components.queryItems?.append(URLQueryItem(name: secretKey, value: secret))
        let versionKey = "version"
        guard let version = required[versionKey] as? Int else{
            throw QueryError.keyNotFound(key: versionKey)
        }
        components.queryItems?.append(URLQueryItem(name: versionKey, value: String(version)))

        switch self{
            case .categories:
                components.path = "categories"
                return URLRequest(url: components.url(relativeTo: base)!)
            case .random(let options):
                components.queryItems = components.queryItems! + options.query // I wish I could use += instead of being forced to unwrap the optional
                components.path = "random"
                return URLRequest(url: components.url(relativeTo: base)!)
        }
    }
}
