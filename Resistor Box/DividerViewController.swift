//
//  DividerViewController.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-03-16.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class DividerViewController: BaseViewController {

    @IBOutlet weak var divider1Image: UIImageView!
    @IBOutlet weak var divider1Activity: UIActivityIndicatorView!
    
    @IBOutlet weak var divider2Image: UIImageView!
    @IBOutlet weak var divider2Activity: UIActivityIndicatorView!
    
    var divider : Double = 0.5 {
        didSet {
            desiredValue.title = "Ratio(x): " + stringFrom(divider)
        }
    }
    
    func updateDivider1Resistors (_ x : [Double], label: String)  {
        let color = Store.colors[preferences.color1]!
        update(x, prefix: label, image: divider1Image, color: color, imageFunc: ResistorImage.imageOfVoltageDivider)
    }
    
    func updateDivider2Resistors (_ x : [Double], label: String) {
        let color = Store.colors[preferences.color2]!
        update(x, prefix: label, image: divider2Image, color: color, imageFunc: ResistorImage.imageOfVoltageDivider2)
    }
    
    @IBAction func updateValues(_ sender: Any) {
        divider = Double(desiredValue.title!.replacingOccurrences(of: "Ratio(x): ", with: "")) ?? 0.5
        minR = Resistors.parseString(String(minResistance.title!.dropFirst()))
        calculateOptimalValues()
    }
    
    override func formatValue(_ x: Double) -> String {
        return "Ratio(x): " + stringFrom(x)
    }
    
    override func refreshGUI (_ x : [Double], y : [Double], z : [Double], label : String) {
        super.refreshGUI(x, y: y, z: z, label: label)
        if calculating1 { updateDivider1Resistors(x, label: label) }
        if calculating2 { updateDivider2Resistors(y, label: label) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateOptimalValues()
    }
    
    override func refreshAll() {
        super.refreshAll()
        let label = "Best"
        updateDivider1Resistors(x, label: label)
        updateDivider2Resistors(y, label: label)
    }
    
    override func calculateOptimalValues() {
        super.calculateOptimalValues()
        performCalculations("divider 1", value: divider, start: minR.0, x: &x, compute: Resistors.computeDivider1(_:start:callback:done:),
                            calculating: &calculating1, update: updateDivider1Resistors(_:label:), activity: divider1Activity)
        performCalculations("divider 2", value: divider, start: minR.0, x: &y, compute: Resistors.computeDivider2(_:start:callback:done:),
                            calculating: &calculating2, update: updateDivider2Resistors(_:label:), activity: divider2Activity)
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
                vc.picker = NumberPicker(maxValue: Decimal(string: "1.99999")!, andIncrement: Decimal(string: "1.0")!)
                vc.picker.maxValue = 1
                vc.value = desiredValue.title!.replacingOccurrences(of: "Ratio(x): ", with: "")
                if let vc = destNav as? MenuViewController {
                    vc.base = self
                }
                vc.callback = { [weak self] newValue in
                    guard let wself = self else { return }
                    wself.divider = Double(newValue) ?? 1
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
