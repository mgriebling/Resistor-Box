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
    @IBOutlet weak var cancelButton: UIButton!
    
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
        cancelButton.isEnabled = false
        calculateOptimalValues(desiredValue)
    }
    
    // make sure these variables are retained
    var r = (0.0, "")
    var x = [Double]()
    var y = [Double]()
    var finished : Int = 0

    @IBAction func calculateOptimalValues(_ sender: UITextField) {
        r = Resistors.parseString(sender.text ?? "0Ω")
        seriesActivity.startAnimating()
        seriesParallelActivity.startAnimating()
        Resistors.cancelCalculations = false
        cancelButton.isEnabled = true
        desiredValue.isEnabled = false
        finished = 0
        backgroundQueue.async {
            print("Starting series calculations...")
            self.x = Resistors.computeSeries(self.r.0, callback: { (value, error, r1, r2, r3) in
                self.updateSeriesResistors(value, error:error, r1:r1, r2: r2, r3: r3, label: "Working")
            }, done: { x in
                DispatchQueue.main.async {
                    self.updateSeriesResistors(x[3], error:x[4], r1: x[0], r2: x[1], r3: x[2], label: "Best")
                    self.seriesActivity.stopAnimating()
                    print("Finished series calculations...")
                    self.finished += 1
                    if self.finished == 2 {
                        self.cancelButton.isEnabled = false
                        self.desiredValue.isEnabled = true
                    }
                }
            })
        }
        backgroundQueue.async {
            print("Starting series/parallel calculations...")
            self.y = Resistors.computeSeriesParallel(self.r.0, callback: { (value, error, r1, r2, r3) in
                self.updateSeriesParallelResistors(value, error:error, r1:r1, r2: r2, r3: r3, label: "Working")
            }, done: { x in
                DispatchQueue.main.async {
                    self.updateSeriesParallelResistors(self.y[3], error:self.y[4], r1: self.y[0], r2: self.y[1], r3: self.y[2], label: "Best")
                    self.seriesParallelActivity.stopAnimating()
                    print("Finished series/parallel calculations...")
                    self.finished += 1
                    if self.finished == 2 {
                        self.cancelButton.isEnabled = false
                        self.desiredValue.isEnabled = true
                    }
                }
            })
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

