//
//  OpAmpGainViewController.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-02-15.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class OpAmpGainViewController: BaseViewController {
    
    @IBOutlet weak var gainImage: UIImageView!
    @IBOutlet weak var gainIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var invertingGainImage: UIImageView!
    @IBOutlet weak var invertingGainIndicator: UIActivityIndicatorView!
    
    var gain : Double = 2.5 {
        didSet {
            desiredValue.title = "Gain(x): " + stringFrom(gain)
        }
    }
    
    func updateGainResistors (_ x : [Double], label: String) {
        let color = ColorPicker.colors[preferences.color1]!
        update(x, prefix: label, image: gainImage, color: color, imageFunc: ResistorImage.imageOfOpAmpGain2)
    }
    
    func updateInvertingGainResistors (_ x : [Double], label: String) {
        let color = ColorPicker.colors[preferences.color2]!
        update(x, prefix: label, image: invertingGainImage, color: color, imageFunc: ResistorImage.imageOfOpAmpGain)
    }
    
    @IBAction func updateValues(_ sender: Any) {
        gain = Double(desiredValue.title!.replacingOccurrences(of: "Gain(x): ", with: "")) ?? 1
        let r = minResistance.title!.dropFirst()
        minR = Resistors.parseString(String(r))
        calculateOptimalValues()
    }
    
    override func formatValue(_ x: Double) -> String {
        return "Gain: " + stringFrom(x)
    }
    
    override func refreshGUI (_ x : [Double], y : [Double], z : [Double], label : String) {
        super.refreshGUI(x, y: y, z: z, label: label)
        if calculating1 { updateGainResistors(x, label: label) }
        if calculating2 { updateInvertingGainResistors(y, label: label) }
    }
    
    override func refreshAll() {
        super.refreshAll()
        let label = "Best"
        updateGainResistors(x, label: label)
        updateInvertingGainResistors(y, label: label)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateOptimalValues()
    }
    
    override func calculateOptimalValues() {
        super.calculateOptimalValues()
        performCalculations("gain 1", value: gain, start: minR.0, x: &x, compute: Resistors.computeGain, calculating: &calculating1,
                            update: updateGainResistors(_:label:), activity: gainIndicator)
        performCalculations("gain 2", value: gain, start: minR.0, x: &y, compute: Resistors.computeInvertingGain, calculating: &calculating2,
                            update: updateInvertingGainResistors(_:label:), activity: invertingGainIndicator)
        enableGUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destNav = segue.destination
        let popPC = destNav.popoverPresentationController
        popover = popPC
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
                vc.value = desiredValue.title?.replacingOccurrences(of: "Gain(x): ", with: "")
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
        case "showMenu":
            if let vc = destNav as? MenuViewController {
                vc.base = self
            }
        default: break
        }
    }
    
}

