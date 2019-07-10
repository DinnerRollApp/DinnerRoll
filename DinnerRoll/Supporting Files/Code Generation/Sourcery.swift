//
//  Sourcery.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 3/31/19.
//  Copyright © 2019 Michael Hulet. All rights reserved.
//

protocol AutoEncodable: Encodable{}
protocol AutoDecodable: Decodable{}
typealias AutoCodable = AutoEncodable & AutoDecodable

protocol AutoCoding: NSCoding{}
