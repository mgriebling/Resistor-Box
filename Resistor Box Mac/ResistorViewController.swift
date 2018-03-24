//
//  ResistorViewMController.swift
//  Resistor Box Mac
//
//  Created by Michael Griebling on 2018-03-12.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import Cocoa

class ResistorViewController: BaseViewController {
    
    @IBOutlet weak var seriesResistors: NSImageView!
    @IBOutlet weak var seriesActivity: NSProgressIndicator!
    
    @IBOutlet weak var seriesParallelResistors: NSImageView!
    @IBOutlet weak var seriesParallelActivity: NSProgressIndicator!
    
    @IBOutlet weak var parallelResistors: NSImageView!
    @IBOutlet weak var parallelActivity: NSProgressIndicator!
    
    // make sure these variables are retained
    var r = (10.0, 10.0, "Ω") {
        didSet {
            DispatchQueue.main.async {
                self.desiredValue.stringValue = String(Resistors.stringFrom(self.r.1).dropLast())
            }
        }
    }
    
    override func formatValue(_ x: Double) -> String {
        return "Total: " + Resistors.stringFrom(x)
    }
    
    func updateSeriesResistors (_ x : [Double], label: String) {
        update(x, prefix: label, image: seriesResistors, imageFunc: ResistorImage.imageOfSeriesResistors(value1:value2:value3:), label: seriesLabel)
    }
    
    func updateSeriesParallelResistors (_ x : [Double], label: String) {
        update(x, prefix: label, image: seriesParallelResistors, imageFunc: ResistorImage.imageOfSeriesParallelResistors(value1:value2:value3:), label: seriesParallelLabel)
    }
    
    func updateParallelResistors (_ x : [Double], label: String) {
        update(x, prefix: label, image: parallelResistors, imageFunc: ResistorImage.imageOfParallelResistors(value1:value2:value3:), label: parallelLabel)
    }
    
    func refreshGUI (_ x : [Double], y : [Double], z : [Double], label : String) {
        if calculating1 { updateSeriesResistors(x, label: label) }
        if calculating2 { updateSeriesParallelResistors(y, label: label) }
        if calculating3 { updateParallelResistors(z, label: label) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // install a swipe gesture to display user settings
        let gesture = UISwipeGestureRecognizer()
        
        calculateOptimalValues()
    }
    
    func calculateOptimalValues() {
        guard !(calculating1 || calculating2 || calculating3) else { print("ERROR!!!!!!"); return }
        Resistors.cancelCalculations = false
        timedTask = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.refreshGUI(self.x, y: self.y, z: self.z, label: "Working")
        }
        timedTask?.fire()     // refresh GUI to start
        
        performCalculations("series", value: r.0, start: 0, x: &x, compute: Resistors.computeSeries(_:start:callback:done:),
                            calculating: &calculating1, update: updateSeriesResistors(_:label:), activity: seriesActivity)
        performCalculations("series/parallel", value: r.0, start: 0, x: &y, compute: Resistors.computeSeriesParallel(_:start:callback:done:),
                            calculating: &calculating2, update: updateSeriesParallelResistors(_:label:), activity: seriesParallelActivity)
        performCalculations("parallel", value: r.0, start: 0, x: &x, compute: Resistors.computeParallel(_:start:callback:done:),
                            calculating: &calculating3, update: updateParallelResistors(_:label:), activity: parallelActivity)

        enableGUI()
    }
        
    @IBAction func calculateDesiredValue(_ sender: NSTextField) {
        print("Calculating values...")
        r = Resistors.parseString(sender.stringValue + ohmsSelector.stringValue)
        calculateOptimalValues()
    }
}
