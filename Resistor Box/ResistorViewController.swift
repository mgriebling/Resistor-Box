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
            seriesResistors.image = ResistorImage.imageOfSeriesResistors(value1: "???", value2: "???", valu3: "???")
        }
    }
    @IBOutlet weak var seriesLabel: UILabel!
    @IBOutlet weak var seriesActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var seriesParallelResistors: UIImageView!  {
        didSet {
            seriesParallelResistors.image = ResistorImage.imageOfSeriesParallelResistors(value1: "???", value2: "???", valu3: "???")
        }
    }
    @IBOutlet weak var seriesParallelLabel: UILabel!
    @IBOutlet weak var seriesParallelActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var parallelResistors: UIImageView! {
        didSet {
            parallelResistors.image = ResistorImage.imageOfParallelResistors(value1: "???", value2: "???", valu3: "???")
        }
    }
    @IBOutlet weak var parallelLabel: UILabel!
    @IBOutlet weak var parallelActivity: UIActivityIndicatorView!

    @IBOutlet weak var desiredValue: UITextField! {
        didSet { desiredValue.delegate = self }
    }
    
    @IBAction func returnToResistorView(_ segue: UIStoryboardSegue?) {
         view.endEditing(true)
    }
    
    func updateSeriesResistors (_ error: Double, r1: Double, r2: Double, r3: Double, label: String) {
        let r1v = Resistors.stringFrom(r1)
        let r2v = Resistors.stringFrom(r2)
        let r3v = Resistors.stringFrom(r3)
        let rt = Resistors.stringFrom(r1+r2+r3)
        DispatchQueue.main.async {
            self.seriesResistors.image = ResistorImage.imageOfSeriesResistors(value1: r1v, value2: r2v, valu3: r3v)
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 3
            let errorString = formatter.string(from: NSNumber(value: error))!
            self.seriesLabel.text = "\(label) Result: \(rt); error: \(errorString)% with 1% resistors"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
        desiredValue.text = "103.7Ω"
        calculateOptimalValues(desiredValue)
    }

    @IBAction func calculateOptimalValues(_ sender: UITextField) {
        seriesLabel.text = "Finding best solution..."
        seriesActivity.startAnimating()
        let r = Resistors.parseString(sender.text ?? "0Ω")
        DispatchQueue.global().async {
            let x = Resistors.computeSeries(r.0) { (error, r1, r2, r3) in
                self.updateSeriesResistors(error, r1:r1, r2: r2, r3: r3, label: "Working")
            }
            print(x)
            self.updateSeriesResistors(x[4], r1: x[0], r2: x[1], r3: x[2], label: "Best")
            DispatchQueue.main.async {
                self.seriesActivity.stopAnimating()
            }
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
                    self?.desiredValue.text = newValue
                    self?.calculateOptimalValues(self!.desiredValue)
                    self?.view.endEditing(true)
                }
            }
            let popPC = destNav.popoverPresentationController
            popPC?.delegate = self
        }
    }

}

extension ResistorViewController : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

extension ResistorViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

