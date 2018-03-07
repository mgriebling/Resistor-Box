//
//  Resistors.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-02-15.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import Foundation

class Resistors {
    
    static let OPEN  = 1.0e12
    static let SHORT = 1.0e-12
    static let MEG   = 1.0e6
    static let K     = 1.0e3
    
    static var rInv = [String: [Double]]()  // dictionary of resistor values organized by name
    static var callback : (Double, Double, Double, Double) -> () = { a, b, c, d in  }
    
    static let r1pc = [  // 1% minimum: 1 ohm, maximum: 10M ohm
        10.0, 10.2, 10.5, 10.7, 11.0, 11.3, 11.5, 11.8, 12.1, 12.4, 12.7, 13.0,
        13.3, 13.7, 14.0, 14.3, 14.7, 15.0, 15.4, 15.8, 16.2, 16.5, 16.9, 17.4,
        17.8, 18.2, 18.7, 19.1, 19.6, 20.0, 20.5, 21.0, 21.5, 22.1, 22.6, 23.2,
        23.7, 24.3, 24.9, 25.5, 26.1, 26.7, 27.4, 28.0, 28.7, 29.4, 30.1, 30.9,
        31.6, 32.4, 33.2, 34.0, 34.8, 35.7, 36.5, 37.4, 38.3, 39.2, 40.2, 41.2,
        42.2, 43.2, 44.2, 45.3, 46.4, 47.5, 48.7, 49.9, 51.1, 52.3, 53.6, 54.9,
        56.2, 57.6, 59.0, 60.4, 61.9, 63.4, 64.9, 66.5, 68.1, 69.8, 71.5, 73.2,
        75.0, 76.8, 78.7, 80.6, 82.5, 84.5, 86.6, 88.7, 90.9, 93.1, 95.3, 97.6]
    
    static let r5pc = [  // 5% minimum: 1 ohm, maximum: 56M ohm
        1.0, 1.1, 1.2, 1.3, 1.5, 1.6, 1.8, 2.0, 2.2, 2.4, 2.7, 3.0,
        3.3, 3.6, 3.9, 4.3, 4.7, 5.1, 5.6, 6.2, 6.8, 7.5, 8.2, 9.1
    ]
    
    static let r10pc = [  // 10% minimum: 2.2 ohm, maximum: 1M ohm
        10.0, 12.0, 15.0, 18.0, 22.0, 27.0, 33.0, 39.0, 47.0, 56.0, 68.0, 82.0
    ]
    
    static func computeValuesFor(_ rpc : [Double], minimum: Double, maximum: Double, name: String) {
        var r = [Double]()
        var scale = minimum
        outer:
        while scale < 100.0*MEG {
            for resistor in rpc {
                if resistor*scale > maximum { break outer }
                r.append(resistor*scale)
            }
            scale *= 10
        }
        
        // also add OPEN and SHORT
        r.append(OPEN); r.append(SHORT)
        rInv[name] = r
    }
    
    static func clearInventory() { rInv = [String: [Double]]() }
    
    static func initInventory() {
        if rInv.count == 0 {
            // build up the 10% collection
            computeValuesFor(r10pc, minimum: 2.2, maximum: 1.0*MEG, name: "10%")
            
            // build up the 5% collection
            computeValuesFor(r5pc, minimum: 1, maximum: 56.0*MEG, name: "5%")
            
            // build up the 1% collection
            computeValuesFor(r1pc, minimum: 1, maximum: 10.0*MEG, name: "1%")
        }
    }
    
    static func stringFrom(_ r: Double) -> String {
        // Return a string representation for the r value
        var ext = "Ω"
        var r = r
        if r == OPEN {
            return "Open"
        } else if r <= SHORT {
            return "Short"
        } else {
            if      r >= MEG { r /= MEG; ext = "MΩ" }
            else if r >= K   { r /= K; ext = "KΩ" }
            else if r < 0.1  { r *= K; ext = "mΩ" }
            
            var s = String(format: "%15.3f", r).trimmingCharacters(in: CharacterSet.whitespaces)
            while s.hasSuffix("0") { s.removeLast() }
            if s.hasSuffix(".") { s.removeLast() }
            return s+ext
        }
    }
    
    static func parseString(_ s: String) -> (Double, String) {
        // Identify the resistor value from the passed string
        var subRs = s.trimmingCharacters(in: CharacterSet.whitespaces)
        var scale = 1.0
        var suffix = "Ω"
        
        if subRs.hasSuffix("Ω") { subRs.removeLast(); suffix = "Ω" }
        if subRs.hasSuffix("m") { subRs.removeLast(); scale = 1.0/K; suffix = "mΩ" }
        subRs = subRs.uppercased()
        if subRs.hasSuffix("K")  { subRs.removeLast(); scale = K; suffix = "KΩ"  }
        if subRs.hasSuffix("M")  { subRs.removeLast(); scale = MEG; suffix = "MΩ"  }
        if subRs.hasSuffix("MEG")  { subRs.removeLast(3); scale = MEG; suffix = "MΩ"  }
        return ((Double(subRs) ?? 0)*scale, suffix)
    }
    
    static func compute(_ x: Double, withAlgorithm algorithm: (Double, Double, Double) -> (Double), abortAlgorithm abort: (Double, Double, Double, Double) -> Bool) -> [Double] {
        var Re = 1.0e100  // very large error to start
        var Ri, Rj, Rk : Double
        Ri = 0; Rj = 0; Rk = 0
        outerLoop: for i in rInv["1%"]! {
            for j in rInv["1%"]! {
                loop: for k in rInv["1%"]! {
                    if Re < 0.001 { break outerLoop }  // abort processing
                    let Rt = algorithm(i, j, k)
                    if abort(Rt, i, j, k) { break loop }
                    let error = fabs(Rt-x)
                    if error < Re {
                        Ri = i; Rj = j; Rk = k; Re = error
                        Resistors.callback(Re, Ri, Rj, Rk)
                    }
                }
            }
        }
        
        let Rt = algorithm(Ri, Rj, Rk)
        return [Ri, Rj, Rk, Rt, x != 0 ? (100.0*fabs(x - Rt)/x) : fabs(x - Rt)]
    }
    
    static func computeSeries(_ x : Double, callback : @escaping (Double, Double, Double, Double) -> ()) -> [Double] {
        Resistors.initInventory()
        Resistors.callback = callback
        return Resistors.compute(x, withAlgorithm: { (r1, r2, r3) -> (Double) in
            return r1 + r2 + r3
        }, abortAlgorithm: { (current, r1, r2, r3) -> Bool in
            // exit early if a solution is unlikely or has been found
            return r3 > x
        })
    }
    
    static func computeParallel(_ x : Double, callback : @escaping (Double, Double, Double, Double) -> ()) -> [Double] {
        Resistors.initInventory()
        Resistors.callback = callback
        return Resistors.compute(x, withAlgorithm: { (r1, r2, r3) -> (Double) in
            return 1.0 / (1.0/r1 + 1.0/r2 + 1.0/r3)
        }, abortAlgorithm: { (current, r1, r2, r3) -> Bool in
            // exit early if a solution has been found
            return false
        })
    }
    
    static func computeSeriesParallel(_ x : Double, callback : @escaping (Double, Double, Double, Double) -> ()) -> [Double] {
        Resistors.initInventory()
        Resistors.callback = callback
        return Resistors.compute(x, withAlgorithm: { (r1, r2, r3) -> (Double) in
            return r1 + 1.0 / (1.0/r2 + 1.0/r3)
        }, abortAlgorithm: { (current, r1, r2, r3) -> Bool in
            // exit early if a solution is unlikely or has been found
            return r1 > x
        })
    }
    
}
