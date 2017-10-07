//
//  MHCoordinatingViewController.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 7/25/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit
import CoreLocation
import QuadratTouch
import SwiftyJSON
import QuartzCore

protocol SearchAreaProviding{
    var searchCenter: CLLocationCoordinate2D { get }
    var searchRadius: CLLocationDistance { get }
}

protocol SearchFilterProviding{
    var openNow: Bool { get }
    var prices: IndexSet { get }
    var categories: [Category] { get }
    var filters: [String] { get }
}

class MHCoordinatingViewController: MHMainViewController{

    //MARK: - Subviews

    @IBOutlet weak var statusBarBackground: UIVisualEffectView!
    @IBOutlet weak var cardContainerView: MHCardView!

    //MARK: - Child View Controllers

    var searchAreaProvider: SearchAreaProviding?
    var searchFilterProvider: SearchFilterProviding?
    weak var mapController: MHMapViewController?
    weak var cardController: MHCardViewController?

    //MARK: - View Controller Lifecycle

    override func viewDidLoad() -> Void{
        super.viewDidLoad()
        cardContainerView.frame = CGRect(origin: CGPoint(x: 0, y: view.frame.height - 100), size: view.frame.size)
        updateStatusBarFrame(with: view.frame.size)
        addObserver(self, forKeyPath: "cardContainerView.center", options: [.new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateStatusBarFrame(with:transitionCoordinator:)), name: .UIApplicationDidChangeStatusBarFrame, object: nil)
    }

    override func viewDidLayoutSubviews() -> Void{
        super.viewDidLayoutSubviews()
        updateLocationButtonFrame()
    }

    //MARK: - Motion Detection

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) -> Void{
        guard let areaProvider = searchAreaProvider, let filterProvider = searchFilterProvider, motion == .motionShake else{
            return
        }
        cardController?.resignFirstResponder()
        setPaneState(.closed, withInitialVelocity: .zero)
        cardController?.restaurantName.text = String()
        cardController?.spinner.startAnimating()
        mapController?.hideAllRestaurants()
        var ids = ""
        for category in filterProvider.categories{
            if !ids.isEmpty{
                ids += ","
            }
            ids += category.id
        }
        let query = [QuadratTouch.Parameter.ll: "\(areaProvider.searchCenter.latitude),\(areaProvider.searchCenter.longitude)", QuadratTouch.Parameter.categoryId: ids.isEmpty ? "4d4b7105d754a06374d81259" : ids, QuadratTouch.Parameter.radius: String(areaProvider.searchRadius), QuadratTouch.Parameter.intent: "browse", QuadratTouch.Parameter.query: filterProvider.filters.joined(separator: " "), QuadratTouch.Parameter.limit: "50"]
        let task = QuadratTouch.Session.sharedSession().venues.search(query) { (result: QuadratTouch.Result) in
            func fail(message: String) -> Void{
                self.cardController?.restaurantName.text = message
            }
            defer{
                self.cardController?.spinner.stopAnimating()
            }
            guard let response = result.response, var venues = JSON(response)["venues"].array else{
                fail(message: "There was an error. Try again?")
                return
            }
            dump(result.URL)
            func deny(venue: JSON) -> Void{
                venues.remove(at: venues.index(of: venue)!)
            }
            var choice: Restaurant? = nil
            while choice == nil{
                guard !venues.isEmpty else{
                    fail(message: "No restaurants match your search 😕")
                    return
                }
                let venue = venues.randomElement
                guard let potential = Restaurant(json: venue) else{
                    venues.remove(at: venues.index(of: venue)!)
                    continue
                }
//                if filterProvider.openNow{
//                    guard let open = potential.isOpen, open else{
//                        deny(venue: venue)
//                        continue
//                    }
//                }
//                if !filterProvider.prices.isEmpty{
//                    guard let price = potential.price, filterProvider.prices.contains(price - 1) else{
//                        deny(venue: venue)
//                        continue
//                    }
//                }
                choice = potential
            }
            if let selection = choice{
                self.mapController?.show(selection)
                self.cardController?.showInformation(for: selection)
            }
        }
        task.start()
    }

    //MARK: - Layout Utilities

    @objc private func updateStatusBarFrame(with size: CGSize, transitionCoordinator: UIViewControllerTransitionCoordinator? = nil) -> Void{
        func layout() -> Void{
            cardContainerView.frame = CGRect(origin: CGPoint(x: cardContainerView.frame.origin.x, y: size.height - 100), size: cardContainerView.frame.size)
            guard UIScreen.main.bounds.size == size else{
                statusBarBackground.isHidden = true
                return
            }
            statusBarBackground.frame = UIApplication.shared.statusBarFrame
            statusBarBackground.isHidden = false
        }
        if let coordinator = transitionCoordinator{
            coordinator.animate(alongsideTransition: { (transition: UIViewControllerTransitionCoordinatorContext) in
                layout()
                self.updateLocationButtonFrame()
            }, completion: nil)
        }
        else{
            layout()
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        updateLocationButtonFrame()
        cardController?.resignFirstResponder()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) -> Void{
        super.viewWillTransition(to: size, with: coordinator)
        updateStatusBarFrame(with: size, transitionCoordinator: coordinator)
    }

    @objc func updateLocationButtonFrame(from notification: Notification? = nil) -> Void{
        guard let mapManager = mapController else{
            return
        }
        let guideForScale: CGFloat
        if view.layoutMargins.right == 0{
            switch UIScreen.main.scale{
                case 3:
                    guideForScale = 20
                case 2:
                    guideForScale = 16
                default:
                    guideForScale = 12
            }
        }
        else{
            guideForScale = view.layoutMargins.right
        }
        let origin = CGPoint(x: view.frame.width - guideForScale - mapManager.locationButton.frame.size.width, y: cardContainerView.frame.origin.y - guideForScale - mapManager.locationButton.frame.size.height)
        mapManager.locationButton.frame = CGRect(origin: origin, size: mapManager.locationButton.frame.size)
    }

    //MARK: - Initialization and Deinitialization

    deinit{
        searchAreaProvider = nil
        NotificationCenter.default.removeObserver(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "card"{
            guard let controller = segue.destination as? MHCardViewController else{
                return
            }
            searchFilterProvider = controller
            cardController = controller
        }
        else if segue.identifier == "map"{
            guard let controller = segue.destination as? MHMapViewController else{
                return
            }
            searchAreaProvider = controller
            mapController = controller
        }
    }
}
