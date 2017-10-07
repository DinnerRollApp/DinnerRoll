//
//  MHCardViewController.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 7/25/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit
import MultiSelectSegmentedControl

class MHCardViewController: UIViewController, SearchFilterProviding{
    var openNow: Bool{
        get{
            return openNowSwitch.isOn
        }
    }
    var prices: IndexSet{
        get{
            return pricingSegments.selectedSegmentIndexes
        }
    }
    var categories: [Category]{
        get{
            var types = [Category]()
            for tag in filterView.tagView.tagViews where tag is MHCategoryTag{
                types.append((tag as! MHCategoryTag).category)
            }
            return types
        }
    }
    var filters: [String]{
        get{
            var searches = [String]()
            for tag in filterView.tagView.tagViews where !(tag is MHCategoryTag){
                guard let text = tag.currentTitle else{
                    continue
                }
                searches.append(text)
            }
            return searches
        }
    }

    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var filterView: MHFilterView!
    @IBOutlet weak var openNowSwitch: UISwitch!
    @IBOutlet weak var pricingSegments: MultiSelectSegmentedControl!
    
    @discardableResult override func resignFirstResponder() -> Bool{
        super.resignFirstResponder()
        return filterView.searchBar.resignFirstResponder()
    }

    func showInformation(`for` restaurant: Restaurant){
        restaurantName.text = restaurant.name
    }
}
