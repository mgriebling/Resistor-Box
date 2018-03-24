//
//  PowerViewController.swift
//  Resistor Box
//
//  Created by Mike Griebling on 23 Mar 2018.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class PowerViewController: BaseViewController {

    @IBOutlet weak var feedbackButton: UIBarButtonItem!
    @IBOutlet weak var power1Image: UIImageView!
    @IBOutlet weak var power1Activity: UIActivityIndicatorView!
    
    @IBOutlet weak var power2Image: UIImageView!
    @IBOutlet weak var power2Activity: UIActivityIndicatorView!
    
    var outputVoltage : Double = 5.0 {
        didSet {
            desiredValue.title = BaseViewController.formatter.string(from: NSNumber(value: outputVoltage))! + "V"
        }
    }
    var feedbackVoltage : Double = 1.25 {
        didSet {
             feedbackButton.title = BaseViewController.formatter.string(from: NSNumber(value: feedbackVoltage))! + "V"
        }
    }
    var minR = (10_000.0, 10.0, "KΩ") {
        didSet {
            minResistance.title = ">" + Resistors.stringFrom(minR.0)
        }
    }
    
    func updatePower1Resistors (_ x : [Double], label: String) {
        update(x, prefix: label, image: power1Image, imageFunc: ResistorImage.imageOfPowerSupply)
    }
    
    func updatePower2Resistors (_ x : [Double], label: String) {
        update(x, prefix: label, image: power2Image, imageFunc: ResistorImage.imageOfPowerSupply2)
    }
    
    @IBAction func updateValues(_ sender: Any) {
        outputVoltage = Double(desiredValue.title!.dropLast()) ?? 0.5
        minR = Resistors.parseString(String(minResistance.title!.dropFirst()))
        calculateOptimalValues()
    }
    
    override func formatValue(_ x: Double) -> String {
        return "Vout: " + BaseViewController.formatter.string(from: NSNumber(value: feedbackVoltage/x))! + "V"
    }
    
    func refreshGUI (_ x : [Double], y : [Double], label : String) {
        if calculating1 { updatePower1Resistors(x, label: label) }
        if calculating2 { updatePower2Resistors(y, label: label) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateOptimalValues()
    }
    
    func calculateOptimalValues () {
        guard !(calculating1 || calculating2) else { print("ERROR!!!!!!"); return }
        Resistors.cancelCalculations = false
        timedTask = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.refreshGUI(self.x, y: self.y, label: "Working")
        }
        timedTask?.fire()     // refresh GUI to start
        
        performCalculations("power 1", value: feedbackVoltage/outputVoltage, start: minR.0, x: &x, compute: Resistors.computeDivider1(_:start:callback:done:),
                            calculating: &calculating1, update: updatePower1Resistors(_:label:), activity: power1Activity)
        performCalculations("power 2", value: feedbackVoltage/outputVoltage, start: minR.0, x: &y, compute: Resistors.computeDivider2(_:start:callback:done:),
                            calculating: &calculating2, update: updatePower2Resistors(_:label:), activity: power2Activity)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destNav = segue.destination
        let popPC = destNav.popoverPresentationController
        popPC?.delegate = self
        switch segue.identifier! {
        case "EditResistance":
            if let vc = destNav.childViewControllers.first as? ResistancePickerViewController {
                let r = minResistance.title!.dropFirst()  // remove ">"
                vc.value = String(r)
                vc.callback = { [weak self] newValue in
                    guard let wself = self else { return }
                    wself.minR = Resistors.parseString(newValue)
                    wself.calculateOptimalValues()
                }
            }
        case "EditGain":
            if let vc = destNav.childViewControllers.first as? NumberPickerViewController {
                vc.value = String(desiredValue.title!.dropLast())  // remove "V"
                vc.callback = { [weak self] newValue in
                    guard let wself = self else { return }
                    wself.outputVoltage = Double(newValue) ?? 1
                    wself.calculateOptimalValues()
                }
            }
        case "SelectCollection":
            if let vc = destNav.childViewControllers.first as? CollectionViewController {
                vc.value = collectionButton.title
                vc.callback = { [weak self] newValue in
                    guard let wself = self else { return }
                    wself.collectionButton.title = newValue
                    Resistors.active = newValue
                    wself.calculateOptimalValues()
                }
            }
        default: break
        }
    }

}
