//
//  Decimal+Double.swift
//  Solinst
//
//  Created by Michael Griebling on 30Sep2016.
//  Copyright © 2016 Solinst Canada. All rights reserved.
//

import Foundation

extension Decimal {
    
    // make this a bit easier to use
    
    public var double : Double {
        return (self as NSDecimalNumber).doubleValue
    }
    
}
