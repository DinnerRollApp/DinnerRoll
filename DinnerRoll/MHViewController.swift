//
//  ViewController.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 4/14/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit
import MapKit
import QuadratTouch
import INTULocationManager

class MHViewController: UIViewController{
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    override func viewDidLoad() -> Void{
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
            let radius: Double = 1000
            let search = Session.sharedSession().venues.search([QuadratTouch.Parameter.ll: "\(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude)", QuadratTouch.Parameter.llAcc: "\(currentLocation.horizontalAccuracy)", QuadratTouch.Parameter.alt: "\(currentLocation.altitude)", QuadratTouch.Parameter.altAcc: "\(currentLocation.verticalAccuracy)", QuadratTouch.Parameter.categoryId: "4d4b7105d754a06374d81259", QuadratTouch.Parameter.radius: String(radius), QuadratTouch.Parameter.limit: "50"], completionHandler:{(result: QuadratTouch.Result) in
                guard let response = result.response else{
                    return
                }
                //To display a full circle, you have to display the diameter, plus a little padding to show the whole pin
                let mapSize = radius * 2 + 500
                self.map.setRegion(MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, mapSize, mapSize), animated: true)
                self.map.removeAnnotations(self.map.annotations)
                let restaurant = (response["venues"]! as! [[String: Any]]).randomElement
                print(restaurant)
                let annotation = MKPointAnnotation()
                //print(type(of: (restaurant["location"] as! [String: Any])["lat"]!))
                //annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees((restaurant["location"] as! [String: Any])["lat"] as! NSNumber)!, longitude: CLLocationDegrees((restaurant["location"] as! [String: Any])["lng"] as! String)!)
                annotation.coordinate = CLLocationCoordinate2D(latitude: ((restaurant["location"] as! [String: Any])["lat"] as! NSNumber).doubleValue, longitude: ((restaurant["location"] as! [String: Any])["lng"] as! NSNumber).doubleValue)
                self.map.addAnnotation(annotation)
                self.restaurantLabel.text = restaurant["name"]! as? String
                self.spinner.stopAnimating()
                self.refreshButton.isHidden = false
            })
            search.start()
        }
    }
}
