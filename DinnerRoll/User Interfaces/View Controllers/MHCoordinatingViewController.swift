//
//  MHCoordinatingViewController.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 7/25/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
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

    @IBOutlet var statusBarBackground: UIVisualEffectView!
    @IBOutlet var cardContainerView: MHCardView!

    //MARK: - Child View Controllers

    var searchAreaProvider: SearchAreaProviding?
    var searchFilterProvider: SearchFilterProviding?
    weak var mapController: MHMapViewController?
    weak var cardController: MHCardViewController?

    //MARK: - View Controller Lifecycle

    override func viewDidLoad() -> Void{
        super.viewDidLoad()
        cardOpenFrame = CGRect(origin: CGPoint(x: 0, y: 100), size: view.frame.size)
        updateStatusBarFrame(with: view.frame.size)
        addObserver(self, forKeyPath: #keyPath(cardContainerView.center), options: [.new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateStatusBarFrame(with:transitionCoordinator:)), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(roll), name: .shouldRollAgain, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) -> Void{
        super.viewWillAppear(animated)
    }

    override func viewDidLayoutSubviews() -> Void{
        let safeAreaHeight: CGFloat
        if #available(iOS 11, *){
            safeAreaHeight = view.safeAreaInsets.bottom
        }
        else{
            safeAreaHeight = 0
        }
        cardClosedFrame = CGRect(origin: CGPoint(x: 0, y: view.frame.height - (cardController?.closedVisibileHeight ?? 0) - (safeAreaHeight / 2)), size: view.frame.size)
        if paneState == .closed{
            cardContainerView.frame = cardClosedFrame
        }
        updateLocationButtonFrame()
        super.viewDidLayoutSubviews()
    }

    //MARK: - Motion Detection

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) -> Void{
        super.motionEnded(motion, with: event)
        if motion == .motionShake{
            NotificationCenter.default.post(name: .shouldRollAgain, object: nil)
        }
    }

    @objc func roll() -> Void{
        guard let areaProvider = searchAreaProvider, let filterProvider = searchFilterProvider else{
            return
        }
        cardController?.resignFirstResponder()
        setPaneState(.closed, withInitialVelocity: .zero)
        cardController?.optionButtonsView.isHidden = true
        cardController?.spinner.startAnimating()
        mapController?.hideAllRestaurants()
        // TODO: Hit my server and download data
        let options = API.RandomOptions(location: areaProvider.searchCenter, radius: areaProvider.searchRadius, openNow: filterProvider.openNow, price: filterProvider.prices, categories: filterProvider.categories, filters: filterProvider.filters)
        request(API.random(options: options)).responseData{(response: DataResponse<Data>) in
            defer{
                self.cardController?.optionButtonsView.isHidden = false
                self.cardController?.spinner.stopAnimating()
            }
            guard response.error == nil, let raw = response.value, let restaurant = try? JSONDecoder().decode(Restaurant.self, from: raw) else{
                if response.response?.statusCode == 404{
                    //self.displayError(message: "No matches 😞")
                }
                else{
                    //self.displayError()
                }
                return
            }
            self.mapController?.show(restaurant)
            self.cardController?.showInformation(for: restaurant)
        }
    }

    //MARK: - Layout Utilities

    @objc private func updateStatusBarFrame(with size: CGSize, transitionCoordinator: UIViewControllerTransitionCoordinator? = nil) -> Void{
        func layout() -> Void{
            cardContainerView.frame = CGRect(origin: CGPoint(x: cardContainerView.frame.origin.x, y: size.height - 128), size: cardContainerView.frame.size)
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
        removeObserver(self, forKeyPath: #keyPath(cardContainerView.center))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "card", let controller = segue.destination as? MHCardViewController{
            searchFilterProvider = controller
            cardController = controller
        }
        else if segue.identifier == "map", let controller = segue.destination as? MHMapViewController{
            searchAreaProvider = controller
            mapController = controller
        }
    }
}

extension Notification.Name{
    static let shouldRollAgain = Notification.Name("MHShouldRollAgainNotification")
}
