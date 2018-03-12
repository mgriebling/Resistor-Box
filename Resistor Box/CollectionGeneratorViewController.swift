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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        newToleranceSelected(selectedPercent)
    }
    
    func setValues(_ tolerance: String) {
        nameField.text = "My \(tolerance)"
        startLabel.setTitle("10Ω", for: .normal)
        endLabel.setTitle("10MΩ", for: .normal)
        updateTotalResistors(tolerance)
    }
    
    func updateTotalResistors(_ tolerance: String) {
        let start : [Double]
        switch tolerance {
        case "1%": start = Resistors.r1pc
        case "5%": start = Resistors.r5pc
        default:   start = Resistors.r10pc
        }
        let collection = Resistors.computeValuesFor(start, minimum: 10, maximum: 10*Resistors.MEG)
        estimatedNumber.text = "Estimated number of resistors: \(collection.count)"
    }
    
    @IBAction func saveCollection(_ sender: Any) {
    }
    
    @IBAction func newToleranceSelected(_ sender: UISegmentedControl) {
        let selected = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        setValues(selected)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectStart" || segue.identifier == "SelectEnd" {
            let destNav = segue.destination
            if let vc = destNav.childViewControllers.first as? NumberPickerViewController {
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
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
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
