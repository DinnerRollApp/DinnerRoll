//
//  MHRestaurantDetailView.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 4/13/19.
//  Copyright © 2019 Michael Hulet. All rights reserved.
//

import UIKit
import Cosmos

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
        self.init(arrangedSubviews: subviews)
        axis = .vertical
        alignment = .fill
    }
}
