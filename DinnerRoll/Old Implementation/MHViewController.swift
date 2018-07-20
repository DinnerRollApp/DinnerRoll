//
//  ViewController.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 4/14/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import CoreLocation

class MHViewController: MHMainViewController, MKMapViewDelegate, DBMapSelectorManagerDelegate, CLLocationManagerDelegate{
    @IBOutlet weak var cardView: MHCardView!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var grabberView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var statusBarBackground: UIVisualEffectView!
    var selectionCircle: DBMapSelectorManager? = nil
    let locationManager = CLLocationManager()

//    override var canBecomeFirstResponder: Bool{
//        get{
//            return true
//        }
//    }

    func layoutFrames() -> Void{
        map.frame = view.frame
        cardView.frame = CGRect(x: 0, y: view.frame.size.height - 100, width: view.frame.width, height: cardView.frame.size.height)
        cardView.center = CGPoint(x: view.center.x, y: view.frame.size.height + (cardView.frame.size.height / 2) - 100)
        restaurantLabel.frame = CGRect(x: 8, y: restaurantLabel.frame.origin.y, width: cardView.frame.size.width - 16, height: restaurantLabel.frame.size.height)
        spinner.center = restaurantLabel.center
        grabberView.center = CGPoint(x: cardView.center.x, y: grabberView.center.y)
        separatorView.frame = CGRect(x: 8, y: view.frame.size.height - cardView.frame.origin.y, width: cardView.frame.size.width - 16, height: 1)
        if UIScreen.main.bounds == view.bounds{
            statusBarBackground.frame = UIApplication.shared.statusBarFrame
        }
    }

    override func viewDidLoad() -> Void{
        super.viewDidLoad()
        map.delegate = self
        selectionCircle = DBMapSelectorManager(mapView: map)
        selectionCircle?.delegate = self
        selectionCircle?.editingType = .full
        selectionCircle?.circleRadius = 1000
        selectionCircle?.fillColor = #colorLiteral(red: 0.9843137255, green: 0.9019607843, blue: 0, alpha: 1)
        selectionCircle?.strokeColor = #colorLiteral(red: 0.03921568627, green: 0.1450980392, blue: 0.7411764706, alpha: 1)
        selectionCircle?.pointColor = #colorLiteral(red: 0.9843137255, green: 0.9019607843, blue: 0, alpha: 1)
        selectionCircle?.textColor = #colorLiteral(red: 0.03991333395, green: 0.1469032466, blue: 0.7415332794, alpha: 1)
        selectionCircle?.lineColor = #colorLiteral(red: 0.9803921569, green: 0.5607843137, blue: 0, alpha: 1)
        selectionCircle?.centerPinColor = #colorLiteral(red: 0.03921568627, green: 0.1450980392, blue: 0.7411764706, alpha: 1)
        cardView.layer.cornerRadius = 10
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowRadius = 3
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        separatorView.layer.cornerRadius = 1
        NotificationCenter.default.addObserver(self, selector: #selector(reactToCardViewUpdate), name: Notification.Name.MHCardDidDragNotificationName, object: nil)
        updateCategories()
        layoutFrames()
        refresh()
    }
//    override func resignFirstResponder() -> Bool{
//        let _ = super.resignFirstResponder()
//        return false
//    }
//    override func viewWillAppear(_ animated: Bool) -> Void{
//        super.viewWillAppear(animated)
//        becomeFirstResponder()
//        print(next)
//    }
    override func viewDidAppear(_ animated: Bool) -> Void{
        super.viewDidAppear(animated)
        //becomeFirstResponder()
        //TODO: Handle if the user declines location authorization
        if CLLocationManager.authorizationStatus() == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
        print(cardView.frame)
    }
    func refresh() -> Void{
        restaurantLabel.text = ""
        spinner.startAnimating()
        spinner.isHidden = false
        guard let currentLocation = map.userLocation.location else{
            return
        }
        map.removeAnnotations(map.annotations)
        if selectionCircle!.circleCoordinate == CLLocationCoordinate2D(){
            selectionCircle?.circleCoordinate = currentLocation.coordinate
        }
        selectionCircle?.applySelectorSettings()
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) -> Void{
        super.motionEnded(motion, with: event)
        guard motion == .motionShake else{
            return
        }
        refresh()
    }

    @objc func reactToCardViewUpdate() -> Void{
        //print(cardView.frame)
    }

    //MARK: - MKMapViewDelegate Conformance

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        return selectionCircle!.mapView(mapView, rendererFor: overlay)
    }

    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) -> Void{
        selectionCircle?.mapView(mapView, annotationView: annotationView, didChange: newState, fromOldState: oldState)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        return selectionCircle?.mapView(mapView, viewFor: annotation)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) -> Void{
        selectionCircle?.mapView(mapView, regionDidChangeAnimated: animated)
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) -> Void{
        userLocation.title = ""
        guard selectionCircle?.circleCoordinate == CLLocationCoordinate2D() else{
            return
        }
        refresh()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        layoutFrames()
    }
}

extension CLLocationCoordinate2D: Equatable{
    public static func ==(right: CLLocationCoordinate2D, left: CLLocationCoordinate2D) -> Bool{
        return right.latitude == left.latitude && right.longitude == left.longitude
    }
    public static func !=(right: CLLocationCoordinate2D, left: CLLocationCoordinate2D) -> Bool{
        return right.latitude != left.latitude || right.longitude != left.longitude
    }
}

class MHLayoutSupporter: NSObject, UILayoutSupport{
    var length: CGFloat = 0
    var topAnchor: NSLayoutYAxisAnchor
    var heightAnchor: NSLayoutDimension
    var bottomAnchor: NSLayoutYAxisAnchor

    init(top: NSLayoutYAxisAnchor, bottom: NSLayoutYAxisAnchor, height: NSLayoutDimension){
        topAnchor = top
        bottomAnchor = bottom
        heightAnchor = height
    }
}
