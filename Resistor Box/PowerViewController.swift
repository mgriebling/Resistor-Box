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
            desiredValue.title = "V₀: " + stringFrom(outputVoltage) + "V"
        }
    }
    var feedbackVoltage : Double = 2.5 {
        didSet {
            feedbackButton.title = "V₊: " + stringFrom(feedbackVoltage) + "V"
        }
    }
    
    func updatePower1Resistors (_ x : [Double], label: String) {
        let color = ColorPicker.colors[preferences.color1]!
        update(x, prefix: label, image: power1Image, color: color, imageFunc: ResistorImage.imageOfPowerSupply)
    }
    
    func updatePower2Resistors (_ x : [Double], label: String) {
        let color = ColorPicker.colors[preferences.color2]!
        update(x, prefix: label, image: power2Image, color: color, imageFunc: ResistorImage.imageOfPowerSupply2)
    }
    
    @IBAction func updateValues(_ sender: Any) {
        outputVoltage = Double(desiredValue.title!.dropFirst(3)) ?? 5
        minR = Resistors.parseString(String(minResistance.title!.dropFirst()))
        calculateOptimalValues()
    }
    
    override func formatValue(_ x: Double) -> String {
        guard x != 0 else { return "∞" }
        return "V₀: " + stringFrom(feedbackVoltage/x) + "V"
    }
    
    override func refreshGUI (_ x : [Double], y : [Double], z : [Double], label : String) {
        super.refreshGUI(x, y: y, z: z, label: label)
        if calculating1 { updatePower1Resistors(x, label: label) }
        if calculating2 { updatePower2Resistors(y, label: label) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateOptimalValues()
    }
    
    override func refreshAll() {
        super.refreshAll()
        let label = "Best"
        updatePower1Resistors(x, label: label)
        updatePower2Resistors(y, label: label)
    }
    
    override func enableGUI() {
        super.enableGUI()
        feedbackButton.isEnabled = !calculating1 && !calculating2
    }
    
    override func calculateOptimalValues() {
        super.calculateOptimalValues()
        performCalculations("power 1", value: feedbackVoltage/outputVoltage, start: minR.0, x: &x, compute: Resistors.computeDivider1(_:start:callback:done:),
                            calculating: &calculating1, update: updatePower1Resistors(_:label:), activity: power1Activity)
        performCalculations("power 2", value: feedbackVoltage/outputVoltage, start: minR.0, x: &y, compute: Resistors.computeDivider2(_:start:callback:done:),
                            calculating: &calculating2, update: updatePower2Resistors(_:label:), activity: power2Activity)

        enableGUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destNav = segue.destination
        let popPC = destNav.popoverPresentationController
        popover = popPC
        popPC?.delegate = self
        switch segue.identifier {
//        case "EditResistance":
//            if let vc = destNav.childViewControllers.first as? ResistancePickerViewController {
//                let r = minResistance.title!.dropFirst()  // remove ">"
//                vc.value = String(r)
//                vc.callback = { [weak self] newValue in
//                    self?.minR = Resistors.parseString(newValue)
//                    self?.calculateOptimalValues()
//                }
//            }
        case "EditVout":
            if let vc = destNav.childViewControllers.first as? NumberPickerViewController {
                vc.value = String(desiredValue.title!.dropLast().dropFirst(4))  // remove "V"
                vc.callback = { [weak self] newValue in
                    self?.outputVoltage = Double(newValue) ?? 0
                    self?.calculateOptimalValues()
                }
            }
        case "EditVf":
            if let vc = destNav.childViewControllers.first as? NumberPickerViewController {
                vc.value = String(feedbackButton.title!.dropLast().dropFirst(4))  // remove "V"
                vc.callback = { [weak self] newValue in
                    self?.feedbackVoltage = Double(newValue) ?? 0
                    self?.calculateOptimalValues()
                }
            }
//        case "SelectCollection":
//            if let vc = destNav.childViewControllers.first as? CollectionViewController {
//                vc.value = collectionButton.title
//                vc.callback = { [weak self] newValue in
//                    self?.collectionButton.title = newValue
//                    Resistors.active = newValue
//                    self?.calculateOptimalValues()
//                }
//            }
        case "showMenu":
            if let vc = destNav as? MenuViewController {
                vc.base = self
            }
        default: break
        }
    }

}
