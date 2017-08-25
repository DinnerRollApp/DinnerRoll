//
//  MHCardViewController.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 7/25/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit

class MHCardViewController: UIViewController{
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var filterView: MHFilterView!

    @discardableResult override func resignFirstResponder() -> Bool{
        super.resignFirstResponder()
        return filterView.searchBar.resignFirstResponder()
    }
}
