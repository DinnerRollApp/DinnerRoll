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
import QuartzCore

protocol SearchAreaProviding{
    var searchCenter: CLLocationCoordinate2D? { get }
    var searchRadius: CLLocationDistance? { get }
}

class MHCoordinatingViewController: MHMainViewController{

    //MARK: - Subviews

    @IBOutlet weak var statusBarBackground: UIVisualEffectView!
    @IBOutlet weak var cardContainerView: MHCardView!

    //MARK: - Child View Controllers

    var searchAreaProvider: SearchAreaProviding?
    weak var mapController: MHMapViewController?
    weak var cardController: MHCardViewController?

    //MARK: - View Controller Lifecycle

    override func viewDidLoad() -> Void{
        super.viewDidLoad()
        cardContainerView.frame = CGRect(origin: CGPoint(x: 0, y: view.frame.height - 100), size: view.frame.size)
        updateStatusBarFrame(with: view.frame.size)
        addObserver(self, forKeyPath: "cardContainerView.center", options: [.new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocationButtonFrame(from:)), name: .UIApplicationDidChangeStatusBarFrame, object: nil)
    }

    override func viewDidLayoutSubviews() -> Void{
        super.viewDidLayoutSubviews()
        updateLocationButtonFrame()
    }

    //MARK: - Layout Utilities

    private func updateStatusBarFrame(with size: CGSize, transitionCoordinator: UIViewControllerTransitionCoordinator? = nil) -> Void{
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
            cardController = (segue.destination as! MHCardViewController)
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
