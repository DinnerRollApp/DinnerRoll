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
    //private var areaSelectionFeedbackGenerator: UISelectionFeedbackGenerator? = nil
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
