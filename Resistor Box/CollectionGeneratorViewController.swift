//
//  CollectionGeneratorViewController.swift
//  Resistor Box
//
//  Created by Mike Griebling on 11 Mar 2018.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class CollectionGeneratorViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField! {
        didSet { nameField.delegate = self }
    }
    @IBOutlet weak var startLabel: UIButton!
    @IBOutlet weak var endLabel: UIButton!
    @IBOutlet weak var selectedPercent: UISegmentedControl!
    @IBOutlet weak var estimatedNumber: UILabel!
    
    @IBAction func returnToResistorView(_ segue: UIStoryboardSegue?) {
        // return to here from exit segue
    }
    
    var collection = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        newToleranceSelected(selectedPercent)
    }
    
    func setValues(_ tolerance: String) {
        nameField.text = "My \(tolerance)"
        let min = Resistors.stringFrom(preferences.minResistance)
        let max = Resistors.stringFrom(preferences.maxResistance)
        startLabel.setTitle(min, for: .normal)
        endLabel.setTitle(max, for: .normal)
        updateTotalResistors(tolerance)
    }
    
    func updateTotalResistors(_ tolerance: String) {
        let start : [Int16]
        switch tolerance {
        case "0.1%",
             "0.25%",
             "0.5%": start = Resistors.r0p1pc
        case "1%":   start = Resistors.r1pc
        case "2%":   start = Resistors.r2pc
        case "5%":   start = Resistors.r5pc
        case "10%":  start = Resistors.r10pc
        default:     start = Resistors.r1pc
        }
        let minimum = Resistors.parseString(startLabel.title(for: .normal) ?? "10Ω")
        let maximum = Resistors.parseString(endLabel.title(for: .normal) ?? "10MΩ")
        collection = Resistors.computeValuesFor(start, minimum: minimum.0, maximum: maximum.0)
        estimatedNumber.text = "Estimated number of resistors: \(collection.count)"
    }
    
    @IBAction func saveCollection(_ sender: Any) {
        // ensure we have a unique name
        var name = nameField.text!
        var count = 1
        while let _ = Resistors.sortedKeys().index(of: name) {
            name = nameField.text! + " \(count)"
            count += 1
        }
        
        // add the resistors to the main inventory
        Resistors.rInv[name] = collection
        Resistors.writeInventory()          // save to disk
        collection = []
        
        // exit this pop-up
        performSegue(withIdentifier: "ExitEditor", sender: self)
    }
    
    @IBAction func newToleranceSelected(_ sender: UISegmentedControl) {
        let selected = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        setValues(selected)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectStart" || segue.identifier == "SelectEnd" {
            let destNav = segue.destination
            if let vc = destNav.childViewControllers.first as? ResistancePickerViewController {
                vc.value = segue.identifier == "SelectStart" ? startLabel.titleLabel!.text : endLabel.titleLabel!.text
                vc.callback = { newValue in
                    if segue.identifier == "SelectStart" {
                        self.startLabel.setTitle(newValue, for: .normal)
                    } else {
                        self.endLabel.setTitle(newValue, for: .normal)
                    }
                    let selected = self.selectedPercent.titleForSegment(at: self.selectedPercent.selectedSegmentIndex)!
                    self.updateTotalResistors(selected)
                }
            }
            let popPC = destNav.popoverPresentationController
            popPC?.delegate = self
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // remove the keypad when tapping on the background
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

}

extension CollectionGeneratorViewController : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // allows popover to appear for iPhone-style devices
        return .none
    }
    
}

extension CollectionGeneratorViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
