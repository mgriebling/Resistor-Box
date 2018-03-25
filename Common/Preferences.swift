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
    
    static var color1 : Color = Color(red: 0.929, green: 0.520, blue: 0.520, alpha: 1.000)
    static var color2 : Color = Color(red: 0.719, green: 0.719, blue: 1.000, alpha: 1.000)
    static var color3 : Color = Color(red: 0.519, green: 0.979, blue: 0.519, alpha: 1.000)
    
}

// We extend our ResistorImage class here so it won't be overriden with new auto-generated updates

public extension ResistorImage {
    
    @objc dynamic public class var euroResistor : Bool { return preferences.useEuroSymbols }
    @objc dynamic public class var drawShadows  : Bool { return preferences.useShadows }
    
    //// Colors
    
    @objc dynamic public class var topGradientColor: Color { return preferences.color1 }
    @objc dynamic public class var midGradientColor: Color { return preferences.color2 }
    @objc dynamic public class var bottomGradientColor: Color { return preferences.color3 }
    
}
