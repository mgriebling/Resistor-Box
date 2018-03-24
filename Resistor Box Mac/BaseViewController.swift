//
//  BaseViewMController.swift
//  Resistor Box Mac
//
//  Created by Michael Griebling on 2018-03-21.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import Cocoa

class BaseViewController: NSViewController {
    
    @IBOutlet weak var desiredValue: NSTextField!
    @IBOutlet weak var ohmsSelector: NSComboBox!
    @IBOutlet weak var cancelButton: NSButton!
    
    @IBAction func returnToResistorView(_ segue: NSStoryboardSegue?) { /* Stub for exit returns */ }
    
    var x = [Double]()
    var y = [Double]()
    var z = [Double]()
    
    var timedTask : Timer?
    
    var calculating1 = false
    var calculating2 = false
    var calculating3 = false
    
    let backgroundQueue = DispatchQueue(label: "com.c-inspirations.resistorBox.bgqueue", qos: .background, attributes: DispatchQueue.Attributes.concurrent)
    
    static var formatter : NumberFormatter {
        let f = NumberFormatter()
        f.maximumFractionDigits = 3
        f.minimumIntegerDigits = 1
        return f
    }
    
    static func takePDFOf(_ view: NSView) -> Data? {
//        let renderer = NSGraphicsPDFRenderer(bounds: view.bounds)
//        let data = renderer.pdfData { context in
//            context.beginPage()
//            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
//        }
        return nil
    }
    
    static func takeSnapshotOf(_ view: NSView) -> NSImage? {
//        NSGraphicsBeginImageContext(CGSize(width: view.frame.size.width, height: view.frame.size.height))
//        view.drawHierarchy(in: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height), afterScreenUpdates: true)
//        let image = NSGraphicsGetImageFromCurrentImageContext()
//        NSGraphicsEndImageContext()
        return nil
    }
    
    func formatValue(_ x : Double) -> String {
        // stub to be overridden
        assert(false, "Need to override 'formatValue' method")
        return "Value: \(x)"
    }
    
    @IBAction func cancelCalculations(_ sender: Any) {
        print("Cancelled calculation")
        Resistors.cancelCalculations = true
    }
    
    func update(_ x : [Double], prefix: String, image: NSImageView,
                imageFunc: @escaping (_ value1: String, _ value2: String, _ value3: String) -> (NSImage), label: NSTextField) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
        let rt  = x.count == 0 ? "???" : formatValue(x[3])
        let error = x.count == 0 ? "???" : BaseViewController.formatter.string(from: NSNumber(value: x[4]))!
        image.image = imageFunc(r1v, r2v, r3v)
        label.stringValue = "\(prefix) \(rt); error: \(error)% with \(Resistors.active) resistors"
    }
    
    func performCalculations(_ label : String, value : Double, start: Double, x : inout [Double],
                             compute : @escaping (Double, Double, ([Double]) -> (), ([Double]) -> ()) -> (),
                             calculating : inout Bool, update : @escaping ([Double], String) -> (), activity : NSProgressIndicator) {
        calculating = true
        activity.startAnimation(self)
        activity.isHidden = false
        backgroundQueue.async {
            print("Starting \(label) calculations...")
            compute(value, start, { values in
                x = values   // update working values
            }, { fvalues in
                x = fvalues
                calculating = false
                self.stopTimer()
                DispatchQueue.main.async { [weak self] in
                    update(fvalues, "Best")
                    activity.stopAnimation(self)
                    activity.isHidden = true
                    self?.enableGUI()
                    print("Finished \(label) calculations...")
                }
            })
        }
    }
    
    func enableGUI () {
        let done = !calculating1 && !calculating2 && !calculating3
        cancelButton.isEnabled = !done
        desiredValue.isEnabled = done
        ohmsSelector.isEnabled = done
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Resistors.initInventory()   // build up the values
    }
    
    func stopTimer() {
        if !calculating1 && !calculating2 && !calculating3 {
            timedTask?.invalidate() // stop update timer if done
            timedTask = nil
        }
    }
    
}
