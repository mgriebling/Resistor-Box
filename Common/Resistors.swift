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
fileprivate func ⧦ (r1 : Double, r2 : Double) -> Double {
    if r1 <= Resistors.SHORT && r2 <= Resistors.SHORT { return Resistors.SHORT }
    return (r1*r2)/(r1+r2)
}

class Resistors {
    
    static let OPEN  = 1.0e12
    static let SHORT = 1.0e-12
    static let MEG   = 1.0e6
    static let K     = 1.0e3
    
    static var rInv = [String: [Double]]()  // dictionary of resistor values organized by name
    static var active : String = ""         // currently active resistor collection
    static var cancelCalculations = false   // allow user to abort calculations
    
    static let r0p1pc : [Int16] = [ // 0.5%, 0.25%, 0.1% minimum: 1 ohm, maximum: 10M ohm E192 Standard
        100, 101, 102, 104, 105, 106, 107, 109, 110, 111, 113, 114,
        115, 117, 118, 120, 121, 123, 124, 126, 127, 129, 130, 132,
        133, 135, 137, 138, 140, 142, 143, 145, 147, 149, 150, 152,
        154, 156, 158, 160, 162, 164, 165, 167, 169, 172, 174, 176,
        178, 180, 182, 184, 187, 189, 191, 193, 196, 198, 200, 203,
        205, 208, 210, 213, 215, 218, 221, 223, 226, 229, 232, 234,
        237, 240, 243, 246, 249, 252, 255, 258, 261, 264, 267, 271,
        274, 277, 280, 284, 287, 291, 294, 298, 301, 305, 309, 312,
        316, 320, 324, 328, 332, 336, 340, 344, 348, 352, 357, 361,
        365, 370, 374, 379, 383, 388, 392, 397, 402, 407, 412, 417,
        422, 427, 432, 437, 442, 448, 453, 459, 464, 470, 475, 481,
        487, 493, 499, 505, 511, 517, 523, 530, 536, 542, 549, 556,
        562, 569, 576, 583, 590, 597, 604, 612, 619, 626, 634, 642,
        649, 657, 665, 673, 681, 690, 698, 706, 715, 723, 732, 741,
        750, 759, 768, 777, 787, 796, 806, 816, 825, 835, 845, 856,
        866, 876, 887, 898, 909, 920, 931, 942, 953, 965, 976, 988
    ]
    
    static let r1pc : [Int16] = [  // 1% minimum: 1 ohm, maximum: 10M ohm E96 Standard
        100, 102, 105, 107, 110, 113, 115, 118, 121, 124, 127, 130,
        133, 137, 140, 143, 147, 150, 154, 158, 162, 165, 169, 174,
        178, 182, 187, 191, 196, 200, 205, 210, 215, 221, 226, 232,
        237, 243, 249, 255, 261, 267, 274, 280, 287, 294, 301, 309,
        316, 324, 332, 340, 348, 357, 365, 374, 383, 392, 402, 412,
        422, 432, 442, 453, 464, 475, 487, 499, 511, 523, 536, 549,
        562, 576, 590, 604, 619, 634, 649, 665, 681, 698, 715, 732,
        750, 768, 787, 806, 825, 845, 866, 887, 909, 931, 953, 976
    ]
    
    static let r2pc : [Int16] = [  // 2% minimum: 1 ohm, maximum: 10M ohm E48 Standard
        100, 105, 110, 115, 121, 127, 133, 140, 147, 154, 162, 169,
        178, 187, 196, 205, 215, 226, 237, 249, 261, 274, 287, 301,
        316, 332, 348, 365, 383, 402, 422, 442, 464, 487, 511, 536,
        562, 590, 619, 649, 681, 715, 750, 787, 825, 866, 909, 953
    ]

    static let r5pc : [Int16] = [  // 5% minimum: 1 ohm, maximum: 56M ohm E24 Standard
        10, 11, 12, 13, 15, 16, 18, 20, 22, 24, 27, 30,
        33, 36, 39, 43, 47, 51, 56, 62, 68, 75, 82, 91
    ]
    
    static let r10pc : [Int16] = [  // 10% minimum: 2.2 ohm, maximum: 1M ohm E12 Standard
        10, 12, 15, 18, 22, 27, 33, 39, 47, 56, 68, 82
    ]
    
    static public func computeValuesFor(_ rpc : [Int16], minimum: Double, maximum: Double) -> [Double] {
        var r = [Double]()
        let min = Double(rpc.first!)
        var scale = 1.0
        
        // determine scaling factor
        while min * scale > minimum { scale /= 10.0 }
        
        // calculate the required resistors
        r.append(SHORT)
        outer: while scale < 100.0*MEG {
            for resistor in rpc {
                let value = Double(resistor)*scale
                if value > maximum { break outer }
                if value >= minimum { r.append(value) }
            }
            scale *= 10
        }
        r.append(OPEN)
        return r
    }
    
    static func computeValuesFor(_ rpc : [Int16], minimum: Double, maximum: Double, name: String) {
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
            
            var s = String(format: "%15.3f", locale: Locale.current, r).trimmingCharacters(in: CharacterSet.whitespaces)
            let dp = Locale.current.decimalSeparator ?? "."
            while s.hasSuffix("0") { s.removeLast() }
            if s.hasSuffix(dp) { s.removeLast() }
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
        var rArray = [Double](repeating: 0, count:5)  // not doing this sometimes crashes
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
                        // rArray = [Ri, Rj, Rk, Rt, Re]  -- this sometimes crashes?
                        rArray[0] = Ri;
                        rArray[1] = Rj;
                        rArray[2] = Rk;
                        rArray[3] = Rt;
                        rArray[4] = Re
                        callback(rArray)
                        if error < 1e-10 { break outerLoop }  // abort processing
                    }
                }
            }
        }
        Rt = algorithm(Ri, Rj, Rk)   // Rt may have been overwritten
        return [Ri, Rj, Rk, Rt, Re]
    }
    
    static func computeSeries(_ x : Double, start : Double, callback : ([Double]) -> (), done: ([Double]) -> ()) {
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
    
    static func computeParallel(_ x : Double, start : Double, callback : ([Double]) -> (), done: ([Double]) -> ()) {
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
    
    static func computeSeriesParallel(_ x : Double, start : Double, callback : ([Double]) -> (), done: ([Double]) -> ()) {
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
        var sindex = rArray.startIndex
        if x < rArray.dropFirst().first! {
            sindex = rArray.startIndex  // use SHORT
        } else {
            sindex = rArray.index { value -> Bool in
                // find index of next largest value
                if value > x*0.9 { return true }
                return false
                }!
        }
        let eindex = rArray.index { value -> Bool in
            // find index of next largest value
            if value > x*1.1 { return true }
            return false
            }!

        let r = CountableRange(sindex...eindex)
        let result = Resistors.compute(x, range: r, withAlgorithm: { (r1, r2, r3) -> (Double) in
            // using my parallel ⧦ operator 😀
            return r1 + r2 ⧦ r3
        }, abortAlgorithm: { (current, r1, r2, r3) -> Bool in
            // exit early if a solution is unlikely
            if r1 <= SHORT {
                return false
            } else {
                return current > x
            }
        }, callback: callback)
        done(result)
    }
    
}
