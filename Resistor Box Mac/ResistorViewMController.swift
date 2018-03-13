//
//  ResistorViewMController.swift
//  Resistor Box Mac
//
//  Created by Michael Griebling on 2018-03-12.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import Cocoa

class ResistorViewController: NSViewController {
    
    @IBOutlet weak var desiredValue: NSTextField!
    @IBOutlet weak var ohmsSelector: NSComboBox!
    @IBOutlet weak var cancelButton: NSButton!
    
    @IBOutlet weak var seriesResistors: NSImageView! {
        didSet {
            seriesResistors.image = ResistorImage.imageOfSeriesResistors(value1: "???", value2: "???", value3: "???")
        }
    }
    @IBOutlet weak var seriesLabel: NSTextField!
    @IBOutlet weak var seriesActivity: NSProgressIndicator!
    
    @IBOutlet weak var seriesParallelResistors: NSImageView! {
        didSet {
            seriesParallelResistors.image = ResistorImage.imageOfSeriesParallelResistors(value1: "???", value2: "???", value3: "???")
        }
    }
    @IBOutlet weak var seriesParallelLabel: NSTextField!
    @IBOutlet weak var seriesParallelActivity: NSProgressIndicator!
    
    @IBOutlet weak var parallelResistors: NSImageView! {
        didSet {
            parallelResistors.image = ResistorImage.imageOfParallelResistors(value1: "???", value2: "???", value3: "???")
        }
    }
    @IBOutlet weak var parallelLabel: NSTextField!
    @IBOutlet weak var parallelActivity: NSProgressIndicator!
    
    @IBAction func returnToResistorView(_ segue: NSStoryboardSegue?) {
        // Stub for exit returns
    }
    
    static var formatter : NumberFormatter {
        let f = NumberFormatter()
        f.maximumFractionDigits = 3
        f.minimumIntegerDigits = 1
        return f
    }
    
    let backgroundQueue = DispatchQueue(label: "com.c-inspirations.resistorBox.bgqueue", qos: .background, attributes: DispatchQueue.Attributes.concurrent)
    
    // make sure these variables are retained
    var r = (0.0, 0.0, "") {
        didSet {
            DispatchQueue.main.async {
                self.desiredValue.stringValue = String(Resistors.stringFrom(self.r.1).dropLast())
            }
        }
    }
    var x = [Double]()
    var y = [Double]()
    var z = [Double]()
    var timedTask : Timer?
    var calculating1 = false
    var calculating2 = false
    var calculating3 = false

    func updateSeriesResistors (_ x : [Double], label: String) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
        let rt  = x.count == 0 ? "???" : Resistors.stringFrom(x[3])
        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
//        NSView.animate(withDuration: 0.5) {
            self.seriesResistors.image = ResistorImage.imageOfSeriesResistors(value1: r1v, value2: r2v, value3: r3v)
            self.seriesLabel.stringValue = "\(label) Result: \(rt); error: \(error)% with \(Resistors.active) resistors"
//        }
    }
    
    func updateSeriesParallelResistors (_ x : [Double], label: String) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
        let rt  = x.count == 0 ? "???" : Resistors.stringFrom(x[3])
        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
 //       NSView.animate(withDuration: 0.5) {
            self.seriesParallelResistors.image = ResistorImage.imageOfSeriesParallelResistors(value1: r1v, value2: r2v, value3: r3v)
            self.seriesParallelLabel.stringValue = "\(label) Result: \(rt); error: \(error)% with \(Resistors.active) resistors"
 //       }
    }
    
    func updateParallelResistors (_ x : [Double], label: String) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
        let rt  = x.count == 0 ? "???" : Resistors.stringFrom(x[3])
        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
//        NSView.animate(withDuration: 0.5) {
            self.parallelResistors.image = ResistorImage.imageOfParallelResistors(value1: r1v, value2: r2v, value3: r3v)
            self.parallelLabel.stringValue  = "\(label) Result: \(rt); error: \(error)% with \(Resistors.active) resistors"
//        }
    }
    
    func refreshGUI (_ x : [Double], y : [Double], z : [Double], label : String) {
        if calculating1 { updateSeriesResistors(x, label: label) }
        if calculating2 { updateSeriesParallelResistors(y, label: label) }
        if calculating3 { updateParallelResistors(z, label: label) }
    }
    
    func enableGUI () {
        let done = !calculating1 && !calculating2 && !calculating3
        cancelButton.isEnabled = !done
        desiredValue.isEnabled = done
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Resistors.initInventory()   // build up the values
        r = (10, 10, "Ω")
        calculateOptimalValues()
    }
    
    func stopTimer() {
        if !calculating1 && !calculating2 && !calculating3 {
            timedTask?.invalidate() // stop update timer if done
            timedTask = nil
        }
    }
    
    func calculateOptimalValues() {
        guard !(calculating1 || calculating2 || calculating3) else { print("ERROR!!!!!!"); return }
        calculating1 = true; calculating2 = true; calculating3 = true
        seriesActivity.isHidden = false
        seriesParallelActivity.isHidden = false
        parallelActivity.isHidden = false
        seriesActivity.startAnimation(self)
        seriesParallelActivity.startAnimation(self)
        parallelActivity.startAnimation(self)
        enableGUI()
        Resistors.cancelCalculations = false
        timedTask = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.refreshGUI(self.x, y: self.y, z: self.z, label: "Working")
        }
        timedTask?.fire()     // refresh GUI to start
        backgroundQueue.async {
            print("Starting series calculations...")
            Resistors.computeSeries(self.r.0, callback: { values in
                self.x = values   // update working values
            }, done: { s in
                self.x = s
                self.calculating1 = false
                self.stopTimer()
                DispatchQueue.main.async { [weak self] in
                    self?.updateSeriesResistors(s, label: "Best")
                    self?.seriesActivity.stopAnimation(self)
                    self?.seriesActivity.isHidden = true
                    self?.enableGUI()
                    print("Finished series calculations...")
                }
            })
        }
        backgroundQueue.async {
            print("Starting series/parallel calculations...")
            Resistors.computeSeriesParallel(self.r.0, callback: { values in
                self.y = values   // update working values
            }, done: { sp in
                self.y = sp        // final answer update
                self.calculating2 = false
                self.stopTimer()
                DispatchQueue.main.async { [weak self] in
                    self?.updateSeriesParallelResistors(sp, label: "Best")
                    self?.seriesParallelActivity.stopAnimation(self)
                    self?.seriesParallelActivity.isHidden = true
                    self?.enableGUI()
                    print("Finished series/parallel calculations...")
                }
            })
        }
        backgroundQueue.async {
            print("Starting parallel calculations...")
            Resistors.computeParallel(self.r.0, callback: { values in
                self.z = values   // update working values
            }, done: { p in
                self.z = p        // final answer update
                print("Parallel answer = \(p)")
                self.calculating3 = false
                self.stopTimer()
                DispatchQueue.main.async { [weak self] in
                    self?.updateParallelResistors(p, label: "Best")
                    self?.parallelActivity.stopAnimation(self)
                    self?.parallelActivity.isHidden = false
                    self?.enableGUI()
                    print("Finished parallel calculations...")
                }
            })
        }
    }
    
    @IBAction func cancelCalculations(_ sender: Any) {
        print("Cancelled calculation")
        Resistors.cancelCalculations = true
    }
    
    @IBAction func calculateDesiredValue(_ sender: NSTextField) {
        print("Calculating values...")
        r = Resistors.parseString(sender.stringValue + ohmsSelector.stringValue)
        calculateOptimalValues()
    }
}
