//
//  FirstViewController.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-02-15.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class ResistorViewController: UIViewController {

    @IBOutlet weak var seriesResistors: UIImageView! {
        didSet {
            seriesResistors.image = ResistorImage.imageOfSeriesResistors(value1: "???", value2: "???", value3: "???")
        }
    }
    @IBOutlet weak var seriesLabel: UILabel!
    @IBOutlet weak var seriesActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var seriesParallelResistors: UIImageView!  {
        didSet {
            seriesParallelResistors.image = ResistorImage.imageOfSeriesParallelResistors(value1: "???", value2: "???", value3: "???")
        }
    }
    @IBOutlet weak var seriesParallelLabel: UILabel!
    @IBOutlet weak var seriesParallelActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var parallelResistors: UIImageView! {
        didSet {
            parallelResistors.image = ResistorImage.imageOfParallelResistors(value1: "???", value2: "???", value3: "???")
        }
    }
    @IBOutlet weak var parallelLabel: UILabel!
    @IBOutlet weak var parallelActivity: UIActivityIndicatorView!

    @IBOutlet weak var desiredValue: UITextField! {
        didSet { desiredValue.delegate = self }
    }
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func returnToResistorView(_ segue: UIStoryboardSegue?) {
         view.endEditing(true)
    }
    
    static var formatter : NumberFormatter {
        let f = NumberFormatter()
        f.maximumFractionDigits = 3
        f.minimumIntegerDigits = 1
        return f
    }
    
    let backgroundQueue = DispatchQueue(label: "com.c-inspirations.resistorBox.bgqueue", qos: .background, attributes: DispatchQueue.Attributes.concurrent)
    
    func updateSeriesResistors (_ x : [Double], label: String) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
        let rt  = x.count == 0 ? "???" : Resistors.stringFrom(x[3])
        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
        UIView.animate(withDuration: 0.5) {
            self.seriesResistors.image = ResistorImage.imageOfSeriesResistors(value1: r1v, value2: r2v, value3: r3v)
            self.seriesLabel.text = "\(label) Result: \(rt); error: \(error)% with \(Resistors.active) resistors"
        }
    }
    
    func updateSeriesParallelResistors (_ x : [Double], label: String) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
        let rt  = x.count == 0 ? "???" : Resistors.stringFrom(x[3])
        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
        UIView.animate(withDuration: 0.5) {
            self.seriesParallelResistors.image = ResistorImage.imageOfSeriesParallelResistors(value1: r1v, value2: r2v, value3: r3v)
            self.seriesParallelLabel.text = "\(label) Result: \(rt); error: \(error)% with \(Resistors.active) resistors"
        }
    }
    
    func updateParallelResistors (_ x : [Double], label: String) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
        let rt  = x.count == 0 ? "???" : Resistors.stringFrom(x[3])
        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
        UIView.animate(withDuration: 0.5) {
            self.parallelResistors.image = ResistorImage.imageOfParallelResistors(value1: r1v, value2: r2v, value3: r3v)
            self.parallelLabel.text = "\(label) Result: \(rt); error: \(error)% with \(Resistors.active) resistors"
        }
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
    
    @IBAction func cancelCalculations(_ sender: Any) {
        print("Cancelled calculation")
        Resistors.cancelCalculations = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Resistors.initInventory()   // build up the values
        r = (10, 10, "Ω")
        calculateOptimalValues(desiredValue)
    }
    
    func stopTimer() {
        if !calculating1 && !calculating2 && !calculating3 {
            timedTask?.invalidate() // stop update timer if done
            timedTask = nil
        }
    }
    
    // make sure these variables are retained
    var r = (0.0, 0.0, "") {
        didSet {
            DispatchQueue.main.async {
                self.desiredValue.text = Resistors.stringFrom(self.r.0)
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

    @IBAction func calculateOptimalValues(_ sender: UITextField) {
        guard !(calculating1 || calculating2 || calculating3) else { print("ERROR!!!!!!"); return }
        calculating1 = true; calculating2 = true; calculating3 = true
        seriesActivity.startAnimating()
        seriesParallelActivity.startAnimating()
        parallelActivity.startAnimating()
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
                    self?.seriesActivity.stopAnimating()
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
                    self?.seriesParallelActivity.stopAnimating()
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
                    self?.parallelActivity.stopAnimating()
                    self?.enableGUI()
                    print("Finished parallel calculations...")
                }
            })
        }
    }
    
    @IBAction func editingDidBegin(_ sender: UITextField) {
        performSegue(withIdentifier: "PresentPicker", sender: sender)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // remove the keypad when tapping on the background
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PresentPicker" {
            let destNav = segue.destination
            if let vc = destNav.childViewControllers.first as? NumberPickerViewController {
                vc.value = desiredValue.text
                vc.callback = { [weak self] newValue in
                    guard let wself = self else { return }
                    wself.r = Resistors.parseString(newValue)
                    wself.calculateOptimalValues(wself.desiredValue)
                    wself.view.endEditing(true)
                }
            }
            let popPC = destNav.popoverPresentationController
            popPC?.delegate = self
        }
    }

}

extension ResistorViewController : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // allows popover to appear for iPhone-style devices
        return .none
    }
    
}

extension ResistorViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

