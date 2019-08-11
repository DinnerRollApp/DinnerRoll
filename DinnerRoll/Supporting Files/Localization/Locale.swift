//
//  Locale.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 8/10/19.
//  Copyright © 2019 Michael Hulet. All rights reserved.
//

import Foundation

extension Locale{
    static var preferredAgnosticCurrencySymbol: String{
        get{
            var finalSymbol: String? = nil
            for language in self.preferredLanguages.reversed(){
                if let symbol = Locale(identifier: language).currencySymbol, symbol.count == 1{
                    finalSymbol = symbol
                }
            }
            return finalSymbol ?? "$"
        }
    }
}
