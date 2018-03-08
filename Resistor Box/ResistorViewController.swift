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
    
    func updateSeriesResistors (_ result: Double, error: Double, r1: Double, r2: Double, r3: Double, label: String) {
        let r1v = Resistors.stringFrom(r1)
        let r2v = Resistors.stringFrom(r2)
        let r3v = Resistors.stringFrom(r3)
        let rt = Resistors.stringFrom(result)
        DispatchQueue.main.async {
            self.seriesResistors.image = ResistorImage.imageOfSeriesResistors(value1: r1v, value2: r2v, value3: r3v)
            let errorString = ResistorViewController.formatter.string(from: NSNumber(value: error))!
            self.seriesLabel.text = "\(label) Result: \(rt); error: \(errorString)% with 1% resistors"
        }
    }
    
    func updateSeriesParallelResistors (_ result: Double, error: Double, r1: Double, r2: Double, r3: Double, label: String) {
        let r1v = Resistors.stringFrom(r1)
        let r2v = Resistors.stringFrom(r2)
        let r3v = Resistors.stringFrom(r3)
        let rt = Resistors.stringFrom(result)
        DispatchQueue.main.async {
            self.seriesParallelResistors.image = ResistorImage.imageOfSeriesParallelResistors(value1: r1v, value2: r2v, value3: r3v)
            let errorString = ResistorViewController.formatter.string(from: NSNumber(value: error))!
            self.seriesParallelLabel.text = "\(label) Result: \(rt); error: \(errorString)% with 1% resistors"
        }
    }
    
    @IBAction func cancelCalculations(_ sender: Any) {
        print("Cancelled calculation")
        Resistors.cancelCalculations = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
        desiredValue.text = "10Ω"
        Resistors.initInventory()   // build up the values
        calculateOptimalValues(desiredValue)
    }

    @IBAction func calculateOptimalValues(_ sender: UITextField) {
        let r = Resistors.parseString(sender.text ?? "0Ω")
        seriesActivity.startAnimating()
        Resistors.cancelCalculations = false
        backgroundQueue.async {
            print("Starting series calculations...")
            let x = Resistors.computeSeries(r.0) { (value, error, r1, r2, r3) in
                self.updateSeriesResistors(value, error:error, r1:r1, r2: r2, r3: r3, label: "Working")
            }
            DispatchQueue.main.async {
                self.updateSeriesResistors(x[3], error:x[4], r1: x[0], r2: x[1], r3: x[2], label: "Best")
                self.seriesActivity.stopAnimating()
                print("Finished series calculations...")
            }
        }
        seriesParallelActivity.startAnimating()
        backgroundQueue.async {
            print("Starting series/parallel calculations...")
            let x = Resistors.computeSeriesParallel(r.0) { (value, error, r1, r2, r3) in
                self.updateSeriesParallelResistors(value, error:error, r1:r1, r2: r2, r3: r3, label: "Working")
            }
            DispatchQueue.main.async {
                self.updateSeriesParallelResistors(x[3], error:x[4], r1: x[0], r2: x[1], r3: x[2], label: "Best")
                self.seriesParallelActivity.stopAnimating()
                print("Finished series/parallel calculations...")
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
                    self?.view.endEditing(true)
                    self?.calculateOptimalValues(self!.desiredValue)
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

