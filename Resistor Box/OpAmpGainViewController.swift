//
//  SecondViewController.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-02-15.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class OpAmpGainViewController: UIViewController {
    
    @IBOutlet weak var desiredValue: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var gainImage: UIImageView!
    @IBOutlet weak var gainIndicator: UIActivityIndicatorView!
    @IBOutlet weak var gainLabel: UILabel!
    @IBOutlet weak var invertingGainImage: UIImageView!
    @IBOutlet weak var invertingGainIndicator: UIActivityIndicatorView!
    @IBOutlet weak var invertingGainLabel: UILabel!
    
    let backgroundQueue = DispatchQueue(label: "com.c-inspirations.resistorBox.bgqueue2", qos: .background, attributes: DispatchQueue.Attributes.concurrent)
    
    var gain : Double = 2.5
    var calculating1 = false
    var calculating2 = false
    var x = [Double]()
    var y = [Double]()
    var timedTask : Timer?
    
    func updateGainResistors (_ x : [Double], label: String) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let rt  = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[3]))!
        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
        UIView.animate(withDuration: 0.5) {
            self.gainImage.image = ResistorImage.imageOfOpAmpGain2(value1: r1v, value2: r2v)
            self.gainLabel.text = "\(label) Result: \(rt); error: \(error)% with \(Resistors.active) resistors"
        }
    }
    
    func updateInvertingGainResistors (_ x : [Double], label: String) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let rt  = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: -x[3]))!
        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
        UIView.animate(withDuration: 0.5) {
            self.invertingGainImage.image = ResistorImage.imageOfOpAmpGain(value1: r1v, value2: r2v)
            self.invertingGainLabel.text = "\(label) Result: \(rt); error: \(error)% with \(Resistors.active) resistors"
        }
    }
    
    func refreshGUI (_ x : [Double], y : [Double], label : String) {
        if calculating1 { updateGainResistors(x, label: label) }
        if calculating2 { updateInvertingGainResistors(y, label: label) }
    }
    
    func enableGUI () {
        let done = !calculating1 && !calculating2
        cancelButton.isEnabled = !done
        desiredValue.isEnabled = done
    }
    
    func stopTimer() {
        if !calculating1 && !calculating2 {
            timedTask?.invalidate() // stop update timer if done
            timedTask = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Resistors.initInventory()   // build up the values
        calculateOptimalValues()
    }

    @IBAction func cancelCalculations(_ sender: Any) {
        print("Cancelled calculation")
        Resistors.cancelCalculations = true
    }
    
    func calculateOptimalValues () {
        guard !(calculating1 || calculating2) else { print("ERROR!!!!!!"); return }
        calculating1 = true; calculating2 = true
        gainIndicator.startAnimating()
        invertingGainIndicator.startAnimating()
        enableGUI()
        Resistors.cancelCalculations = false
        timedTask = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.refreshGUI(self.x, y: self.y, label: "Working")
        }
        timedTask?.fire()     // refresh GUI to start
        backgroundQueue.async {
            print("Starting gain calculations...")
            Resistors.computeGain(self.gain, callback: { values in
                self.x = values   // update working values
            }, done: { s in
                self.x = s
                self.calculating1 = false
                self.stopTimer()
                DispatchQueue.main.async { [weak self] in
                    self?.updateGainResistors(s, label: "Best")
                    self?.gainIndicator.stopAnimating()
                    self?.enableGUI()
                    print("Finished gain calculations...")
                }
            })
        }
        backgroundQueue.async {
            print("Starting inverting gain calculations...")
            Resistors.computeInvertingGain(self.gain, callback: { values in
                self.y = values   // update working values
            }, done: { sp in
                self.y = sp        // final answer update
                self.calculating2 = false
                self.stopTimer()
                DispatchQueue.main.async { [weak self] in
                    self?.updateInvertingGainResistors(sp, label: "Best")
                    self?.invertingGainIndicator.stopAnimating()
                    self?.enableGUI()
                    print("Finished inverting gain calculations...")
                }
            })
        }
    }
    
}

