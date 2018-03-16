//
//  DividerViewController.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-03-16.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class DividerViewController: UIViewController {

    @IBOutlet weak var divisionRatio: UIButton!
    @IBOutlet weak var minResistance: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var divider1Image: UIImageView!
    @IBOutlet weak var divider1Activity: UIActivityIndicatorView!
    @IBOutlet weak var divider1Label: UILabel!
    @IBOutlet weak var divider2Image: UIImageView!
    @IBOutlet weak var divider2Activity: UIActivityIndicatorView!
    @IBOutlet weak var divider2Label: UILabel!
    
    let backgroundQueue = DispatchQueue(label: "com.c-inspirations.resistorBox.bgqueue2", qos: .background, attributes: DispatchQueue.Attributes.concurrent)
    
    var divider : Double = 0.5 {
        didSet {
            divisionRatio.setTitle(ResistorViewController.formatter.string(from: NSNumber(value: divider)), for: .normal)
        }
    }
    var minR = (10_000.0, 10.0, "KΩ") {
        didSet {
            minResistance.setTitle(Resistors.stringFrom(minR.0), for: .normal)
        }
    }
    var calculating1 = false
    var calculating2 = false
    var x = [Double]()
    var y = [Double]()
    var timedTask : Timer?
    
    @IBAction func returnToResistorView(_ segue: UIStoryboardSegue?) {
    }
    
    func updateDivider1Resistors (_ x : [Double], label: String) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let rt  = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[3]))!
        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
        UIView.animate(withDuration: 0.5) {
            self.divider1Image.image = ResistorImage.imageOfVoltageDivider(value1: r1v, value2: r2v)
            self.divider1Label.text = "\(label) Result: \(rt); error: \(error)% with \(Resistors.active) resistors"
        }
    }
    
    func updateDivider2Resistors (_ x : [Double], label: String) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let rt  = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[3]))!
        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
        UIView.animate(withDuration: 0.5) {
            self.divider2Image.image = ResistorImage.imageOfVoltageDivider(value1: r1v, value2: r2v)
            self.divider2Label.text = "\(label) Result: \(rt); error: \(error)% with \(Resistors.active) resistors"
        }
    }
    
    @IBAction func updateValues(_ sender: Any) {
        divider = Double(divisionRatio.title(for: .normal)!) ?? 0.5
        minR = Resistors.parseString(minResistance.title(for: .normal) ?? "10KΩ")
        calculateOptimalValues()
    }
    
    func refreshGUI (_ x : [Double], y : [Double], label : String) {
        if calculating1 { updateDivider1Resistors(x, label: label) }
        if calculating2 { updateDivider2Resistors(y, label: label) }
    }
    
    func enableGUI () {
        let done = !calculating1 && !calculating2
        cancelButton.isEnabled = !done
        divisionRatio.isEnabled = done
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
        divider1Activity.startAnimating()
        divider2Activity.startAnimating()
        enableGUI()
        Resistors.cancelCalculations = false
        timedTask = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.refreshGUI(self.x, y: self.y, label: "Working")
        }
        timedTask?.fire()     // refresh GUI to start
        backgroundQueue.async {
            print("Starting divider 1 calculations...")
            Resistors.computeDivider(self.divider, start: self.minR.0, callback: { values in
                self.x = values   // update working values
            }, done: { s in
                self.x = s
                self.calculating1 = false
                self.stopTimer()
                DispatchQueue.main.async { [weak self] in
                    self?.updateDivider1Resistors(s, label: "Best")
                    self?.divider1Activity.stopAnimating()
                    self?.enableGUI()
                    print("Finished divider 1 calculations...")
                }
            })
        }
        backgroundQueue.async {
            print("Starting divider 2 calculations...")
            Resistors.computeDivider(self.divider, start: self.minR.0, callback: { values in
                self.y = values   // update working values
            }, done: { sp in
                self.y = sp        // final answer update
                self.calculating2 = false
                self.stopTimer()
                DispatchQueue.main.async { [weak self] in
                    self?.updateDivider2Resistors(sp, label: "Best")
                    self?.divider2Activity.stopAnimating()
                    self?.enableGUI()
                    print("Finished divider 2 calculations...")
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditResistance" {
            let destNav = segue.destination
            if let vc = destNav.childViewControllers.first as? ResistancePickerViewController {
                vc.value = minResistance.title(for: .normal)
                vc.callback = { [weak self] newValue in
                    guard let wself = self else { return }
                    wself.minR = Resistors.parseString(newValue)
                    wself.calculateOptimalValues()
                }
            }
            let popPC = destNav.popoverPresentationController
            popPC?.delegate = self
        } else if segue.identifier == "EditGain" {
            let destNav = segue.destination
            if let vc = destNav.childViewControllers.first as? NumberPickerViewController {
                vc.value = divisionRatio.title(for: .normal)
                vc.callback = { [weak self] newValue in
                    guard let wself = self else { return }
                    wself.divider = Double(newValue) ?? 1
                    wself.calculateOptimalValues()
                }
            }
            let popPC = destNav.popoverPresentationController
            popPC?.delegate = self
        }
    }
    
}

extension DividerViewController : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // allows popover to appear for iPhone-style devices
        return .none
    }
    
}
