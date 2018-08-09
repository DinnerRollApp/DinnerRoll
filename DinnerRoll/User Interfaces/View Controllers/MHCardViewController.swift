//
//  MHCardViewController.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 7/25/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit
import MultiSelectSegmentedControl

class MHCardViewController: UIViewController, SearchFilterProviding, UIGestureRecognizerDelegate{
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

    @IBOutlet var restaurantName: UILabel!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var filterView: MHFilterView!
    @IBOutlet var openNowSwitch: UISwitch!
    @IBOutlet var pricingSegments: MultiSelectSegmentedControl!
    
    @discardableResult override func resignFirstResponder() -> Bool{
        super.resignFirstResponder()
        return filterView.searchBar.resignFirstResponder()
    }

    func showInformation(`for` restaurant: Restaurant) -> Void{
        restaurantName.text = restaurant.name
    }

    override func viewWillAppear(_ animated: Bool) -> Void{
        super.viewWillAppear(animated)
        guard let recognizers = view.superview?.gestureRecognizers else{
            return
        }
        for tap in recognizers where tap is UITapGestureRecognizer{
            tap.delegate = self
        }
    }

    func gestureRecognizer(_ gesture: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        guard !touch.isIn(view: pricingSegments) else{
            return false
        }
        for tag in filterView.tagView.tagViews{
            if touch.isIn(view: tag){
                return false
            }
        }
        return true
    }
}

extension UITouch{
    func isIn(view: UIView) -> Bool{
        return view.bounds.contains(location(in: view))
    }
}
