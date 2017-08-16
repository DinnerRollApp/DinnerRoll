//
//  MHMapViewController.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 7/25/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MHMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, DBMapSelectorManagerDelegate, SearchAreaProviding{
    @IBOutlet weak var map: MKMapView!{
        didSet{
            map.delegate = self
            let recognizer = ForceTouchGestureRecognizer(target: self, action: #selector(placePin(with:)))
            if #available(iOS 10, *){
                recognizer.delegate = self
            }
            map.addGestureRecognizer(recognizer)
        }
    }
    @IBOutlet weak var locationButton: MHLocationButton!
    private var selectionCircle: DBMapSelectorManager? = nil{
        didSet{
            selectionCircle?.editingType = .full
            selectionCircle?.circleRadius = 1000
            selectionCircle?.circleRadiusMax = 100_000
            selectionCircle?.fillColor = #colorLiteral(red: 0.9843137255, green: 0.9019607843, blue: 0, alpha: 1)
            selectionCircle?.strokeColor = #colorLiteral(red: 0.03921568627, green: 0.1450980392, blue: 0.7411764706, alpha: 1)
            selectionCircle?.pointColor = #colorLiteral(red: 0.9843137255, green: 0.9019607843, blue: 0, alpha: 1)
            selectionCircle?.textColor = #colorLiteral(red: 0.03991333395, green: 0.1469032466, blue: 0.7415332794, alpha: 1)
            selectionCircle?.lineColor = #colorLiteral(red: 0.9803921569, green: 0.5607843137, blue: 0, alpha: 1)
            selectionCircle?.centerPinColor = #colorLiteral(red: 0.03921568627, green: 0.1450980392, blue: 0.7411764706, alpha: 1)
        }
    }
    var searchCenter: CLLocationCoordinate2D?{
        get{
            return selectionCircle?.circleCoordinate
        }
    }
    var searchRadius: CLLocationDistance?{
        get{
            return selectionCircle?.circleRadius
        }
    }
    private let locationManager = CLLocationManager()
    private var followingUser = false{
        didSet{
            locationButton.currentAction = followingUser ? .follow : .center
        }
    }
    private let centeringAccuracy: CLLocationDistance = 50
    private var selectionCircleIsCentered: Bool{
        get{
            guard let circle = selectionCircle else{
                return false
            }
            guard let mapView = map else{
                return false
            }
            return CLCircularRegion(center: mapView.centerCoordinate, radius: centeringAccuracy, identifier: "Circle Centering Region").contains(circle.circleCoordinate)
        }
    }

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() -> Void{
        super.viewDidLoad()
        selectionCircle = DBMapSelectorManager(mapView: map)
        locationManager.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) -> Void{
        super.viewWillAppear(animated)
        updateLocationButtonVisibility(to: CLLocationManager.authorized().boolean, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) -> Void{
        super.viewDidAppear(animated)
        if CLLocationManager.authorizationStatus() == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) -> Void{
        super.traitCollectionDidChange(previousTraitCollection)
        guard let gestures = map.gestureRecognizers else{
            return
        }
        for recognizer in gestures where recognizer is ForceTouchGestureRecognizer{
            (recognizer as! ForceTouchGestureRecognizer).update(traitCollection: traitCollection)
        }
    }

    // MARK: - Interface Helpers

    @objc private func placePin(with recognizer: ForceTouchGestureRecognizer) -> Void{
        followingUser = false
        guard recognizer.state == .began else{
            if #available(iOS 10, *), areaSelectionFeedbackGenerator != nil{
                areaSelectionFeedbackGenerator = nil
            }
            return
        }
        let touchPoint = recognizer.location(in: recognizer.view!)
        let geoPoint = map.convert(touchPoint, toCoordinateFrom: recognizer.view!)
        selectionCircle?.circleCoordinate = geoPoint
        selectionCircle?.applySelectorSettings()
        if #available(iOS 10, *), let generator = areaSelectionFeedbackGenerator{
            generator.selectionChanged()
        }
    }

    @IBAction func reactToLocationButtonTouch() -> Void{
        guard CLLocationManager.authorized().boolean else{ // We must be authorized for location updates to center the user
            map.centerCoordinate = selectionCircle!.circleCoordinate // Otherwise, just set the map's center to the selection circe's center
            return
        }
        guard !followingUser else{ // Selection circle and map must not be following the user
            followingUser = false // If the circle and the map are following the user, make them stop
            return
        }
        guard map.isUserCentered(accuracy: selectionCircle!.circleRadius < centeringAccuracy ? selectionCircle!.circleRadius : centeringAccuracy) else{ // The user must be centered in the map view
            map.setUserCentered(true, animated: true) // If they aren't make it happen
            return
        }
        followingUser = true // If we've made it here, the user wants the selection area to follow them
        selectionCircle?.circleCoordinate = map.userLocation.coordinate
        selectionCircle?.applySelectorSettings()
    }

    func updateLocationButtonVisibility(to visibility: Bool, animated: Bool = true) -> Void{
        let opacity: CGFloat = visibility ? 1 : 0
        let hiddenStatus = !visibility
        if animated{
            UIView.animate(withDuration: 0.25, animations: {
                self.locationButton.alpha = opacity
            }, completion: {(finished: Bool) in
                self.locationButton.isHidden = hiddenStatus
            })
        }
        else{
            locationButton.alpha = opacity
            locationButton.isHidden = hiddenStatus
        }
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
        guard !CLLocationManager.authorized().boolean else{
            return
        }
        guard let circle = selectionCircle else{
            return
        }
        let visible = !(selectionCircleIsCentered || circle.circleCoordinate == CLLocationCoordinate2D())
        if locationButton.alpha == 0 && visible{
            locationButton.isHidden = !visible
        }
        updateLocationButtonVisibility(to: visible)
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) -> Void{
        userLocation.title = ""
        guard selectionCircle?.circleCoordinate == CLLocationCoordinate2D() || followingUser else{
            return
        }
        selectionCircle?.circleCoordinate = userLocation.coordinate
        selectionCircle?.applySelectorSettings()
    }

    // MARK: - UIGestureRecognizerDelegate Conformance

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        if #available(iOS 10, *){
            areaSelectionFeedbackGenerator = UISelectionFeedbackGenerator()
            areaSelectionFeedbackGenerator?.prepare()
        }
        return true
    }

    // MARK: - CLLocationManagerDelegate Conformance

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) -> Void{
        locationButton.currentAction = .center
        guard !(status == .authorizedAlways || status == .authorizedWhenInUse) else{ // We only need to edit stuff if we're not authorized to use location services
            updateLocationButtonVisibility(to: true) // If we can use location services, the location button should definitely be visible
            return
        }
        updateLocationButtonVisibility(to: !selectionCircleIsCentered && selectionCircle!.circleCoordinate != CLLocationCoordinate2D()) // If the selection circle is centered and is onscreen, we want to hide the button. Otherwise, we want to show it
    }
}

@available(iOS 10, *) fileprivate extension MHMapViewController{
    private static let hapticAssociation = ObjectAssociation<UISelectionFeedbackGenerator>()
    var areaSelectionFeedbackGenerator: UISelectionFeedbackGenerator?{
        get{
            return MHMapViewController.hapticAssociation[self]
        }
        set{
            MHMapViewController.hapticAssociation[self] = newValue
        }
    }
}

extension MKMapView{
    func setUserCentered(_ centered: Bool, animated: Bool) -> Void{
        guard centered else{
            return
        }
        let newRegion = MKCoordinateRegion(center: userLocation.coordinate, span: region.span)
        setRegion(newRegion, animated: true)
    }

    func isUserCentered(accuracy: CLLocationDistance) -> Bool{
        return CLCircularRegion(center: centerCoordinate, radius: accuracy, identifier: "User Centering Region").contains(userLocation.coordinate)
    }
}

extension CLLocationManager{
    static func authorized() -> (boolean: Bool, status: CLAuthorizationStatus){
        let status = CLLocationManager.authorizationStatus()
        return (boolean: status == .authorizedWhenInUse || status == .authorizedAlways, status: status)
    }
}
