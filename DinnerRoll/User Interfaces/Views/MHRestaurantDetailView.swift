//
//  MHRestaurantDetailView.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 4/13/19.
//  Copyright © 2019 Michael Hulet. All rights reserved.
//

import UIKit
import Cosmos
import FormatterKit

class MHRestaurantDetailView: UIStackView {

    convenience init(restaurant: Restaurant){
        var subviews = [UIView]()
        if let subtitle = restaurant.subtitle{
            let subtitleLabel = UILabel(frame: .zero)
            subtitleLabel.text = subtitle
            subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
            subtitleLabel.textColor = .gray
            subviews.append(subtitleLabel)
        }
        if restaurant.categories.count > 0 {
            let categoriesLabel = UILabel(frame: .zero)
            categoriesLabel.font = .preferredFont(forTextStyle: .caption1)
            categoriesLabel.text = TTTArrayFormatter().string(from: restaurant.categories.map({ (category: Category) -> String in
                return category.shortName
            }))
            subviews.append(categoriesLabel)
        }
        if let rating = restaurant.rating{
            var starSettings = CosmosSettings()
            starSettings.fillMode = .precise
            starSettings.updateOnTouch = false
            starSettings.filledColor = #colorLiteral(red: 0.9647058824, green: 0.4823529412, blue: 0.03137254902, alpha: 1)
            starSettings.starSize = 20
            starSettings.starMargin = 5
            let stars = CosmosView(settings: starSettings)
            stars.rating = rating / 2
            subviews.append(stars)
        }
        if let price = restaurant.price{
            let priceLabel = UILabel(frame: .zero)
            priceLabel.font = .preferredFont(forTextStyle: .subheadline)
            priceLabel.text = Locale.preferredAgnosticCurrencySymbol * price
            priceLabel.textColor = UIColor(red: 133, green: 187, blue: 101, alpha: 100)
            subviews.append(priceLabel)
        }
        self.init(arrangedSubviews: subviews)
        axis = .vertical
        alignment = .fill
    }
}
