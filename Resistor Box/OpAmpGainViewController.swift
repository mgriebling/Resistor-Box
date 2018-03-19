//
//  SecondViewController.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-02-15.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class OpAmpGainViewController: UIViewController {
    
    @IBOutlet weak var gainValue: UIBarButtonItem!
    @IBOutlet weak var minResistance: UIBarButtonItem!
    @IBOutlet weak var collectionButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var gainImage: UIImageView!
    @IBOutlet weak var gainIndicator: UIActivityIndicatorView!
    @IBOutlet weak var gainLabel: UILabel!
    @IBOutlet weak var invertingGainImage: UIImageView!
    @IBOutlet weak var invertingGainIndicator: UIActivityIndicatorView!
    @IBOutlet weak var invertingGainLabel: UILabel!
    @IBOutlet weak var toolBar: UIToolbar!
    
    let backgroundQueue = DispatchQueue(label: "com.c-inspirations.resistorBox.bgqueue2", qos: .background, attributes: DispatchQueue.Attributes.concurrent)
    
    var gain : Double = 2.5 {
        didSet {
            gainValue.title = ResistorViewController.formatter.string(from: NSNumber(value: gain))
        }
    }
    var minR = (10_000.0, 10.0, "KΩ") {
        didSet {
            minResistance.title = ">" + Resistors.stringFrom(minR.0)
        }
    }
    var calculating1 = false
    var calculating2 = false
    var x = [Double]()
    var y = [Double]()
    var timedTask : Timer?
    
    @IBAction func returnToResistorView(_ segue: UIStoryboardSegue?) {
    }
    
    func updateGainResistors (_ x : [Double], label: String) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let rt  = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[3]))!
        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
        UIView.animate(withDuration: 0.5) {
            self.gainImage.image = ResistorImage.imageOfOpAmpGain2(value1: r1v, value2: r2v, value3: r3v)
            self.gainLabel.text = "\(label) Gain: \(rt); error: \(error)% with \(Resistors.active) resistors"
        }
    }
    
    func updateInvertingGainResistors (_ x : [Double], label: String) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let rt  = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: -x[3]))!
        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
        UIView.animate(withDuration: 0.5) {
            self.invertingGainImage.image = ResistorImage.imageOfOpAmpGain(value1: r1v, value2: r2v, value3: r3v)
            self.invertingGainLabel.text = "\(label) Gain: \(rt); error: \(error)% with \(Resistors.active) resistors"
        }
    }
    
    @IBAction func updateValues(_ sender: Any) {
        gain = Double(gainValue.title!) ?? 1
        let r = minResistance.title!.dropFirst()
        minR = Resistors.parseString(String(r))
        calculateOptimalValues()
    }
    
    func refreshGUI (_ x : [Double], y : [Double], label : String) {
        if calculating1 { updateGainResistors(x, label: label) }
        if calculating2 { updateInvertingGainResistors(y, label: label) }
    }
    
    @IBAction func sendAction(_ sender: Any) {
        print("Sending result...")
        let graphic = ResistorViewController.takeSnapshotOf(self.parent!.view)!
        let pdf = ResistorViewController.takePDFOf(self.parent!.view)
        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "ResistorBox"
        let file = docPath.appendingPathComponent(fileName).appendingPathExtension("pdf")
        try? pdf?.write(to: file)
        
        let x = UIActivityViewController(activityItems: [graphic, file], applicationActivities: nil)
        if let popoverController = x.popoverPresentationController, let button = sender as? UIBarButtonItem {
            popoverController.barButtonItem = button
        }
        present(x, animated: true, completion: nil)
    }
    
    func enableGUI () {
        let done = !calculating1 && !calculating2
        var items = toolBar.items!
        if items.contains(actionButton) || items.contains(cancelButton) { items.removeLast() }
        if done {
            items.append(actionButton)
        } else {
            items.append(cancelButton)
        }
        toolBar.setItems(items, animated: true)
        gainValue.isEnabled = done
        minResistance.isEnabled = done
        collectionButton.isEnabled = done
    }
    
    func stopTimer() {
        if !calculating1 && !calculating2 {
            timedTask?.invalidate() // stop update timer if done
            timedTask = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Resistors.initInventory()   // build up the values
        calculateOptimalValues()
    }

    @IBAction func cancelCalculations(_ sender: Any) {
        print("Cancelled calculation")
        Resistors.cancelCalculations = true
    }
    
    func calculateOptimalValues () {
        guard !(calculating1 || calculating2) else { print("ERROR!!!!!!"); return }
        calculating1 = true; calculating2 = true
        gainIndicator.startAnimating()
        invertingGainIndicator.startAnimating()
        enableGUI()
        Resistors.cancelCalculations = false
        timedTask = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.refreshGUI(self.x, y: self.y, label: "Working")
        }
        timedTask?.fire()     // refresh GUI to start
        backgroundQueue.async {
            print("Starting gain calculations...")
            Resistors.computeGain(self.gain, start: self.minR.0, callback: { values in
                self.x = values   // update working values
            }, done: { s in
                self.x = s
                self.calculating1 = false
                self.stopTimer()
                DispatchQueue.main.async { [weak self] in
                    self?.updateGainResistors(s, label: "Best")
                    self?.gainIndicator.stopAnimating()
                    self?.enableGUI()
                    print("Finished gain calculations...")
                }
            })
        }
        backgroundQueue.async {
            print("Starting inverting gain calculations...")
            Resistors.computeInvertingGain(self.gain, start: self.minR.0, callback: { values in
                self.y = values   // update working values
            }, done: { sp in
                self.y = sp        // final answer update
                self.calculating2 = false
                self.stopTimer()
                DispatchQueue.main.async { [weak self] in
                    self?.updateInvertingGainResistors(sp, label: "Best")
                    self?.invertingGainIndicator.stopAnimating()
                    self?.enableGUI()
                    print("Finished inverting gain calculations...")
                }
            })
        }
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
                vc.value = gainValue.title
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

extension OpAmpGainViewController : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // allows popover to appear for iPhone-style devices
        return .none
    }
    
}

