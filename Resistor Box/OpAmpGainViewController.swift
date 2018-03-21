//
//  SecondViewController.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-02-15.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class OpAmpGainViewController: BaseViewController {
    
    @IBOutlet weak var gainImage: UIImageView!
    @IBOutlet weak var gainIndicator: UIActivityIndicatorView!
    @IBOutlet weak var gainLabel: UILabel!
    
    @IBOutlet weak var invertingGainImage: UIImageView!
    @IBOutlet weak var invertingGainIndicator: UIActivityIndicatorView!
    @IBOutlet weak var invertingGainLabel: UILabel!
    
    var gain : Double = 2.5 {
        didSet {
            desiredValue.title = ResistorViewController.formatter.string(from: NSNumber(value: gain))
        }
    }
    var minR = (10_000.0, 10.0, "KΩ") {
        didSet {
            minResistance.title = ">" + Resistors.stringFrom(minR.0)
        }
    }
    
    func updateGainResistors (_ x : [Double], label: String) {
        update(x, prefix: label, image: gainImage, imageFunc: ResistorImage.imageOfOpAmpGain2(value1:value2:value3:), label: gainLabel)
    }
    
    func updateInvertingGainResistors (_ x : [Double], label: String) {
        update(x, prefix: label, image: invertingGainImage, imageFunc: ResistorImage.imageOfOpAmpGain(value1:value2:value3:), label: invertingGainLabel)
    }
    
    @IBAction func updateValues(_ sender: Any) {
        gain = Double(desiredValue.title!) ?? 1
        let r = minResistance.title!.dropFirst()
        minR = Resistors.parseString(String(r))
        calculateOptimalValues()
    }
    
    override func formatValue(_ x: Double) -> String {
        return "Gain: " + BaseViewController.formatter.string(from: NSNumber(value: x))!
    }
    
    func refreshGUI (_ x : [Double], y : [Double], label : String) {
        if calculating1 { updateGainResistors(x, label: label) }
        if calculating2 { updateInvertingGainResistors(y, label: label) }
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
        
        performCalculations("gain 1", value: gain, start: minR.0, x: &x, compute: Resistors.computeGain, calculating: &calculating1,
                            update: updateGainResistors(_:label:), activity: gainIndicator)
        performCalculations("gain 2", value: gain, start: minR.0, x: &y, compute: Resistors.computeInvertingGain, calculating: &calculating2,
                            update: updateInvertingGainResistors(_:label:), activity: invertingGainIndicator)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destNav = segue.destination
        let popPC = destNav.popoverPresentationController
        popPC?.delegate = self
        switch segue.identifier! {
        case "EditResistance":
            if let vc = destNav.childViewControllers.first as? ResistancePickerViewController {
                vc.value = String(minResistance.title!.dropFirst())
                vc.callback = { [weak self] newValue in
                    guard let wself = self else { return }
                    wself.minR = Resistors.parseString(newValue)
                    wself.calculateOptimalValues()
                }
            }
        case "EditGain":
            if let vc = destNav.childViewControllers.first as? NumberPickerViewController {
                vc.value = desiredValue.title
                vc.picker = NumberPicker(maxValue: Decimal(string: "99.999")!, andIncrement: Decimal(string: "100.0")!)
                vc.picker.minValue = 1
                vc.callback = { [weak self] newValue in
                    guard let wself = self else { return }
                    wself.gain = Double(newValue) ?? 1
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

