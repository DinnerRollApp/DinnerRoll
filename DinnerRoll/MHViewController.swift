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
import QuadratTouch
import INTULocationManager

class MHViewController: MainViewController, MKMapViewDelegate, DBMapSelectorManagerDelegate{
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var map: MKMapView!
    var selectionCircle: DBMapSelectorManager? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle{
        get{
            return .lightContent
        }
    }
    override func viewDidLoad() -> Void{
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        map.delegate = self
        selectionCircle = DBMapSelectorManager(mapView: map)
        selectionCircle?.delegate = self
        selectionCircle?.editingType = .full
        selectionCircle?.circleRadius = 1000
        selectionCircle?.fillColor = #colorLiteral(red: 1, green: 0.8506348729, blue: 0.4412845969, alpha: 1)
        cardView.layer.cornerRadius = 10
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowRadius = 3
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cardView.frame.size = CGSize(width: view.frame.size.width - 32, height: 334)
        cardView.center = CGPoint(x: view.center.x, y: -74)
        refresh()
    }
    override func viewWillAppear(_ animated: Bool) -> Void{
        super.viewWillAppear(animated)
        map.frame = view.frame
        cardView.frame = CGRect(x: 0, y: cardView.frame.origin.y, width: view.frame.width, height: cardView.frame.size.height)
        restaurantLabel.frame = CGRect(x: 8, y: restaurantLabel.frame.origin.y, width: cardView.frame.size.width - 16, height: restaurantLabel.frame.size.height)
        spinner.center = restaurantLabel.center
    }
    func refresh() -> Void{
        restaurantLabel.text = ""
        spinner.startAnimating()
        spinner.isHidden = false
        INTULocationManager.sharedInstance().requestLocation(withDesiredAccuracy: .block, timeout: 10){(location: CLLocation?, accuracy: INTULocationAccuracy, status: INTULocationStatus) in
            guard let currentLocation = location, accuracy.rawValue >= INTULocationAccuracy.block.rawValue else{
                return
            }
            self.map.removeAnnotations(self.map.annotations)
            //self.map.removeOverlays(self.map.overlays)
            if self.selectionCircle!.circleCoordinate == CLLocationCoordinate2D(){
                self.selectionCircle?.circleCoordinate = currentLocation.coordinate
            }
            self.selectionCircle?.applySelectorSettings()
            let search = Session.sharedSession().venues.search([QuadratTouch.Parameter.ll: "\(self.selectionCircle!.circleCoordinate.latitude),\(self.selectionCircle!.circleCoordinate.longitude)", QuadratTouch.Parameter.llAcc: "\(currentLocation.horizontalAccuracy)", QuadratTouch.Parameter.alt: "\(currentLocation.altitude)", QuadratTouch.Parameter.altAcc: "\(currentLocation.verticalAccuracy)", QuadratTouch.Parameter.categoryId: "4d4b7105d754a06374d81259" , QuadratTouch.Parameter.radius: String(self.selectionCircle!.circleRadius), QuadratTouch.Parameter.limit: "50"], completionHandler:{(result: QuadratTouch.Result) in
                guard let response = result.response else{
                    return
                }
                let data = JSON(response)
                let restaurant = data["venues"].array!.randomElement
                //print(restaurant)
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: restaurant["location"]["lat"].double!, longitude: restaurant["location"]["lng"].double!)
                self.map.addAnnotation(annotation)
                self.restaurantLabel.text = restaurant["name"].string!
                self.spinner.stopAnimating()
            })
            search.start()
        }
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) -> Void{
        guard motion == .motionShake else{
            return
        }
        refresh()
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

}

extension CLLocationCoordinate2D{
    static func ==(right: CLLocationCoordinate2D, left: CLLocationCoordinate2D) -> Bool{
        return right.latitude == left.latitude && right.longitude == left.longitude
    }
}
