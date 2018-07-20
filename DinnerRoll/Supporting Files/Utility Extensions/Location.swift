//
//  Location.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 5/30/18.
//  Copyright © 2018 Michael Hulet. All rights reserved.
//

extension CLLocationCoordinate2D: Equatable{
    public static func ==(right: CLLocationCoordinate2D, left: CLLocationCoordinate2D) -> Bool{
        return right.latitude == left.latitude && right.longitude == left.longitude
    }
    public static func !=(right: CLLocationCoordinate2D, left: CLLocationCoordinate2D) -> Bool{
        return right.latitude != left.latitude || right.longitude != left.longitude
    }
}
