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

class MHMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, DBMapSelectorManagerDelegate, SearchAreaProviding{
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
            //map.setUserTrackingMode(followingUser ? .follow : .none, animated: true)
        }
    }

    override func viewDidLoad() -> Void{
        super.viewDidLoad()
        selectionCircle = DBMapSelectorManager(mapView: map)
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
        guard !followingUser else{ // Selection circle and map must not be following the user
            followingUser = false // If the circle and the map are following the user, make them stop
            return
        }
        guard map.isUserCentered(accuracy: selectionCircle!.circleRadius < 50 ? selectionCircle!.circleRadius : 50) else{ // The user must be centered in the map view
            map.setUserCentered(true, animated: true) // If they aren't make it happen
            return
        }
        followingUser = true // If we've made it here, the user wants the selection area to follow them
        selectionCircle?.circleCoordinate = map.userLocation.coordinate
        selectionCircle?.applySelectorSettings()
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
        return MKCoordinateRegionMakeWithDistance(region.center, accuracy, accuracy).contains(coordinate: userLocation.coordinate)
    }
}

extension MKCoordinateRegion{
    func contains(coordinate: CLLocationCoordinate2D) -> Bool{
        func normalized(angle: CLLocationDegrees) -> CLLocationDegrees{
            let normal = angle.truncatingRemainder(dividingBy: 360)
            return normal < -180 ? -360 - angle : angle > 180 ? 360 - angle : angle
        }

        let latitude = abs(normalized(angle: center.latitude - coordinate.latitude))
        let longitude = abs(normalized(angle: center.longitude - coordinate.longitude))
        return span.latitudeDelta >= latitude && span.longitudeDelta >= longitude
    }
}
