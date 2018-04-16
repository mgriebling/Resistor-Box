//
//  Preferences.swift
//  Resistor Box
//
//  Created by Mike Griebling on 25 Mar 2018.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import Foundation

public struct preferences {
    
    static var useEuroSymbols : Bool = false
    static var useShadows : Bool = true
    
    static var minResistance : Double = 1
    static var maxResistance : Double = 10 * Resistors.MEG
    
    static var color1 = "Salmon"
    static var color2 = "Aqua"
    static var color3 = "Spring"
    
}

// We extend our ResistorImage class here so it won't be overriden with new auto-generated updates

public extension ResistorImage {
    
    @objc dynamic public class var euroResistor : Bool { return preferences.useEuroSymbols }
    @objc dynamic public class var drawShadows  : Bool { return preferences.useShadows }
    
    //// Colors
    
    @objc dynamic public class var topGradientColor: Color { return Store.colors[preferences.color1]! }
    @objc dynamic public class var midGradientColor: Color { return Store.colors[preferences.color2]! }
    @objc dynamic public class var bottomGradientColor: Color { return Store.colors[preferences.color3]! }
    
}
