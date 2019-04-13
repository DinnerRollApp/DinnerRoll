//
//  RestaurantCategory.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 8/4/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit
import Alamofire

struct Category: Codable, Equatable{
    let name: String
    let pluralName: String
    let shortName: String
    let id: String
    private let primary: Bool

    static func getAllRestaurantCategories(completion: @escaping (Swift.Result<[Category], Error>) -> Void) -> Void{
        request(API.categories).responseData { (response: DataResponse<Data>) in
            guard let result = response.value else {
                completion(.failure(response.error!)) // Force-unwrapping is safe here because it we'll only get to this point if there's a failure, and if there's a failure, there's an error
                return
            }
            do{
                completion(.success(try JSONDecoder().decode([Category].self, from: result)))
            }
            catch{
                completion(.failure(error))
            }
        }
    }

    func isPrimary(for restaurant: Restaurant) -> Bool{
        return restaurant.categories.contains(where: { (category: Category) -> Bool in
            return category == self
        }) && primary
    }
}
