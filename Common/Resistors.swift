//
//  Resistors.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-02-15.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import Foundation

// parallel resistance operator definition
infix operator ⧦ : MultiplicationPrecedence
fileprivate func ⧦ (r1 : Double, r2 : Double) -> Double { return (r1*r2)/(r1+r2) }

class Resistors {
    
    static let OPEN  = 1.0e12
    static let SHORT = 1.0e-12
    static let MEG   = 1.0e6
    static let K     = 1.0e3
    
    static var rInv = [String: [Double]]()  // dictionary of resistor values organized by name
    static var active : String = ""         // currently active resistor collection
    static var cancelCalculations = false   // allow user to abort calculations
    
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
    
    static public func computeValuesFor(_ rpc : [Double], minimum: Double, maximum: Double) -> [Double] {
        var r = [Double]()
        let min = rpc.first!
        var scale = 1.0
        
        // determine scaling factor
        while min * scale > minimum { scale /= 10.0 }
        
        // calculate the required resistors
        r.append(SHORT)
        outer: while scale < 100.0*MEG {
            for resistor in rpc {
                let value = resistor*scale
                if value > maximum { break outer }
                if value >= minimum { r.append(resistor*scale) }
            }
            scale *= 10
        }
        r.append(OPEN)
        return r
    }
    
    static func computeValuesFor(_ rpc : [Double], minimum: Double, maximum: Double, name: String) {
        rInv[name] = computeValuesFor(rpc, minimum: minimum, maximum: maximum)
    }
    
    static func clearInventory() { rInv = [String: [Double]]() }
    
    static func name() -> URL {
        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "ResistorBox"
        return docPath.appendingPathComponent(fileName).appendingPathExtension("rbox")
    }
    
    static public func writeInventory() {
        let fname = name()
        let data = NSKeyedArchiver.archivedData(withRootObject: rInv)
        do {
            try data.write(to: fname)
        } catch {
            print("Couldn't write file")
        }
    }
    
    static func getNumber(_ s: String) -> Double? {
        return Double(s.filter({ ch -> Bool in
            return CharacterSet.decimalDigits.contains(ch.unicodeScalar)
        }))
    }
    
    static public func sortedKeys () -> [String] {
        let keys = Resistors.rInv.keys.sorted { (first, second) -> Bool in
            // prefer numerical sorting order if possible
            if let number1 = getNumber(first) {
                if let number2 = getNumber(second) {
                    return number1 < number2
                }
            }
            
            // otherwise use strings
            return first < second
        }
        return keys
    }
    
    static public func initInventory() {
        // attempt to read from the App's directory
        let fname = name()
        if FileManager.default.fileExists(atPath: fname.path) {
            // read the resistor file
            
            if let inventory = NSKeyedUnarchiver.unarchiveObject(withFile: fname.path) as? [String: [Double]] {
                rInv = inventory
            }
        }
 
        if rInv.count == 0 {
            // build up the 10% collection
            computeValuesFor(r10pc, minimum: 1, maximum: 10.0*MEG, name: "10%")
            
            // build up the 5% collection
            computeValuesFor(r5pc, minimum: 1, maximum: 10.0*MEG, name: "5%")
            
            // build up the 1% collection
            computeValuesFor(r1pc, minimum: 1, maximum: 10.0*MEG, name: "1%")
            
            // write out values
            writeInventory()
        }
        Resistors.active = sortedKeys().first!
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
    
    static func parseString(_ s: String) -> (Double, Double, String) {
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
        let value = Double(subRs) ?? 0
        return (value*scale, value, suffix)
    }
    
    static func compute(_ x: Double, range: CountableRange<Int>, withAlgorithm algorithm: (Double, Double, Double) -> (Double),
                        abortAlgorithm abort: (Double, Double, Double, Double) -> Bool, callback : ([Double]) -> ()) -> [Double] {
        var Re = 1.0e100  // very large error to start
        var Ri, Rj, Rk, Rt : Double
        Ri = 0; Rj = 0; Rk = 0; Rt = 0
        outerLoop: for idex in range {
            let i = rInv[active]![idex]
            for j in rInv[active]! {
                loop: for k in rInv[active]! {
                    Rt = algorithm(i, j, k)
                    let error = x != 0 ? 100.0*fabs(Rt-x)/x : Rt
                    if abort(Rt, i, j, k) { break loop }
                    if Resistors.cancelCalculations { break outerLoop }
                    if error < Re {
                        Ri = i; Rj = j; Rk = k; Re = error
                        callback([Ri, Rj, Rk, Rt, Re])
                        if error < 1e-10 { break outerLoop }  // abort processing
                    }
                }
            }
        }
        Rt = algorithm(Ri, Rj, Rk)   // Rt may have been overwritten
        return [Ri, Rj, Rk, Rt, Re]
    }
    
    static func computeSeries(_ x : Double, callback : ([Double]) -> (), done: ([Double]) -> ()) {
        let rArray = rInv[active]!
        if let index = rArray.index(of: x) {
            // return the obvious solution
            let Rs = rArray[index]
            done([Rs, SHORT, SHORT, Rs, 0]); return
        }
        let last = rArray.index(rArray.endIndex, offsetBy: -2)
        let rlast = rArray[last]
        if rlast*3 < x {
            // check for values that are too large
            done([rlast, rlast, rlast, 3*rlast, 100.0*fabs(x-3*rlast)/x]); return
        }
        let r = rArray.indices
        let result = Resistors.compute(x, range: r, withAlgorithm: { (r1, r2, r3) -> (Double) in
            return r1 + r2 + r3
        }, abortAlgorithm: { (current, r1, r2, r3) -> Bool in
            // exit early if a solution is unlikely
            return r3 > x
        }, callback: callback)
        done(result)
    }
    
    static func computeDivider1 (_ x : Double, start : Double, callback : ([Double]) -> (), done: ([Double]) -> ()) {
        let rArray = rInv[active]!
        let sindex : Int
        if let index = rArray.index(of: start) {
            sindex = index
        } else {
            sindex = rArray.index { value -> Bool in
                // find index of next largest value
                if value > start { return true }
                return false
                }!
        }
        
        // check for common gains
        if x >= 1 {
            done([SHORT, OPEN, rArray[sindex], 1, 100.0*fabs(x-1.0)/x]); return
        } else if x == 0.5 {
            done([rArray[sindex], OPEN, rArray[sindex], x, 0]); return
        } else if x == 1.0/3.0 {
            done([rArray[sindex], rArray[sindex], rArray[sindex], x, 0]); return
        }
        
        let r = CountableRange(sindex...rArray.index(before: rArray.endIndex))
        let result = Resistors.compute(x, range: r, withAlgorithm: { (r1, r2, r3) -> (Double) in
            let rp = r2 ⧦ r3
            return rp/(r1+rp)
        }, abortAlgorithm: { (current, r1, r2, r3) -> Bool in
            // exit early if a solution is unlikely
            return false
        }, callback: callback)
        done(result)
    }
    
    static func computeDivider2 (_ x : Double, start : Double, callback : ([Double]) -> (), done: ([Double]) -> ()) {
        let rArray = rInv[active]!
        let sindex : Int
        if let index = rArray.index(of: start) {
            sindex = index
        } else {
            sindex = rArray.index { value -> Bool in
                // find index of next largest value
                if value > start { return true }
                return false
            }!
        }
        
        // check for common gains
        if x >= 1 {
            done([rArray[sindex], OPEN, SHORT, 1, 100.0*fabs(x-1.0)/x]); return
        } else if x == 0.5 {
            done([rArray[sindex], OPEN, rArray[sindex], x, 0]); return
        } else if x == 2.0/3.0 {
             done([rArray[sindex], rArray[sindex], rArray[sindex], x, 0]); return
        }
        
        let r = CountableRange(sindex...rArray.index(before: rArray.endIndex))
        let result = Resistors.compute(x, range: r, withAlgorithm: { (r1, r2, r3) -> (Double) in
            if r1 == SHORT { return 0 }  // avoid an error because SHORTs are not really zero
            let rp = r2 ⧦ r3
            let rn = r1 / (rp + r1)
            return rn
        }, abortAlgorithm: { (current, r1, r2, r3) -> Bool in
            // exit early if a solution is unlikely
            return false
        }, callback: callback)
        done(result)
    }
    
    static func computeGain (_ x : Double, start : Double, callback : ([Double]) -> (), done: ([Double]) -> ()) {
        let rArray = rInv[active]!
        let sindex : Int
        if let index = rArray.index(of: start) {
            sindex = index
        } else {
            sindex = rArray.index { value -> Bool in
                // find index of next largest value
                if value > start { return true }
                return false
            }!
        }
        
        // check for common gains
        if x == 1 {
            done([rArray[sindex], OPEN, OPEN, x, 0]); return
        }
        
        let r = CountableRange(sindex...rArray.index(before: rArray.endIndex))
        let result = Resistors.compute(x, range: r, withAlgorithm: { (r1, r2, r3) -> (Double) in
            return 1.0 + r1 / (r3 ⧦ r2)
        }, abortAlgorithm: { (current, r1, r2, r3) -> Bool in
            // exit early if a solution is unlikely
            return false
        }, callback: callback)
        done(result)
    }
    
    static func computeInvertingGain (_ x : Double, start : Double, callback : ([Double]) -> (), done: ([Double]) -> ()) {
        let rArray = rInv[active]!
        let sindex : Int
        if let index = rArray.index(of: start) {
            sindex = index
        } else {
            sindex = rArray.index { value -> Bool in
                // find index of next largest value
                if value > start { return true }
                return false
            }!
        }
        
        // check for common gains
        if x == 1 {
            done([rArray[sindex], OPEN, rArray[sindex], x, 0]); return
        }
        
        let r = CountableRange(sindex...rArray.index(before: rArray.endIndex))
        let result = Resistors.compute(x, range: r, withAlgorithm: { (r1, r2, r3) -> (Double) in
            return r1 / (r3 ⧦ r2)
        }, abortAlgorithm: { (current, r1, r2, r3) -> Bool in
            // exit early if a solution is unlikely
            return false
        }, callback: callback)
        done(result)
    }
    
    static func computeParallel(_ x : Double, callback : ([Double]) -> (), done: ([Double]) -> ()) {
        let rArray = rInv[active]!
        if let index = rArray.index(of: x) {
            // return the obvious solution
            let Rs = rArray[index]
            done([Rs, OPEN, OPEN, x, 0]); return
        }
        if let index = rArray.index(of: 2*x) {
            // return the obvious solution
            let Rs = rArray[index]
            done([Rs, Rs, OPEN, x, 0]); return
        }
        if let index = rArray.index(of: 3*x) {
            // return the obvious solution
            let Rs = rArray[index]
            done([Rs, Rs, Rs, x, 0]); return
        }
        let last = rArray.index(rArray.endIndex, offsetBy: -2)
        let rlast = rArray[last]
        if rlast < x {
            // check for values that are too large
            done([rlast, OPEN, OPEN, rlast, 100.0*fabs(x-rlast)/x]); return
        }
        // outer loop start from near x value
        let sindex = rArray.index { value -> Bool in
            // find index of next largest value
            if value > x*0.9 { return true }
            return false
        }
        let eindex = rArray.index { value -> Bool in
            // find index of next largest value
            if value > x*1.1 { return true }
            return false
        }
        let r = CountableRange(sindex!...eindex!)
        let result = Resistors.compute(x, range: r, withAlgorithm: { (r1, r2, r3) -> (Double) in
            // using my parallel ⧦ operator 😀
            return r1 ⧦ r2 ⧦ r3
        }, abortAlgorithm: { (current, r1, r2, r3) -> Bool in
            // exit early if a solution is unlikely
            return false
        }, callback: callback)
        done(result)
    }
    
    static func computeSeriesParallel(_ x : Double, callback : ([Double]) -> (), done: ([Double]) -> ()) {
        let rArray = rInv[active]!
        if let index = rArray.index(of: x) {
            // return the obvious solution
            let Rs = rArray[index]
            done([Rs, SHORT, OPEN, Rs, 0]); return
        }
        let last = rArray.index(rArray.endIndex, offsetBy: -2)
        let rlast = rArray[last]
        if rlast*2 < x {
            // check for values that are too large
            done([rlast, rlast, OPEN, 2*rlast, 100.0*fabs(x-2*rlast)/x]); return
        }
        // outer loop start from near x value
        let sindex = rArray.index { value -> Bool in
            // find index of next largest value
            if value > x*0.9 { return true }
            return false
        }
        let eindex = rArray.index { value -> Bool in
            // find index of next largest value
            if value > x*1.1 { return true }
            return false
        }
        let r = CountableRange(sindex!...eindex!)
        let result = Resistors.compute(x, range: r, withAlgorithm: { (r1, r2, r3) -> (Double) in
            // using my parallel ⧦ operator 😀
            return r1 + r2 ⧦ r3
        }, abortAlgorithm: { (current, r1, r2, r3) -> Bool in
            // exit early if a solution is unlikely
            return r1 > x || current > x
        }, callback: callback)
        done(result)
    }
    
}
