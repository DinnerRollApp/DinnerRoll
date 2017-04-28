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

class MHViewController: UIViewController, MKMapViewDelegate, DBMapSelectorManagerDelegate{
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    var selectionCircle: DBMapSelectorManager? = nil
    override func viewDidLoad() -> Void{
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        map.delegate = self
        selectionCircle = DBMapSelectorManager(mapView: map)
        selectionCircle?.delegate = self
        selectionCircle?.editingType = .full
        selectionCircle?.circleRadius = 1000
        refresh()
    }
    @IBAction func refresh() -> Void{
        refreshButton.isHidden = true
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
                //To display a full circle, you have to display the diameter, plus a little padding to show the whole pin
                let restaurant = data["venues"].array!.randomElement
                //print(restaurant)
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: restaurant["location"]["lat"].double!, longitude: restaurant["location"]["lng"].double!)
                self.map.addAnnotation(annotation)
                self.restaurantLabel.text = restaurant["name"].string!
                self.spinner.stopAnimating()
                self.refreshButton.isHidden = false
            })
            search.start()
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

    
}

extension CLLocationCoordinate2D{
    static func ==(right: CLLocationCoordinate2D, left: CLLocationCoordinate2D) -> Bool{
        return right.latitude == left.latitude && right.longitude == left.longitude
    }
}
