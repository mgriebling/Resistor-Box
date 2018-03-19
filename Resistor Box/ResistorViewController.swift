//
//  FirstViewController.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-02-15.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class ResistorViewController: UIViewController {

    @IBOutlet weak var seriesResistors: UIImageView!
    @IBOutlet weak var seriesLabel: UILabel!
    @IBOutlet weak var seriesActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var seriesParallelResistors: UIImageView!
    @IBOutlet weak var seriesParallelLabel: UILabel!
    @IBOutlet weak var seriesParallelActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var parallelResistors: UIImageView!
    @IBOutlet weak var parallelLabel: UILabel!
    @IBOutlet weak var parallelActivity: UIActivityIndicatorView!

    @IBOutlet weak var desiredValue: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var collectionButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBAction func returnToResistorView(_ segue: UIStoryboardSegue?) {
    }
    
    static var formatter : NumberFormatter {
        let f = NumberFormatter()
        f.maximumFractionDigits = 6
        f.minimumIntegerDigits = 1
        return f
    }
    
    let backgroundQueue = DispatchQueue(label: "com.c-inspirations.resistorBox.bgqueue", qos: .background, attributes: DispatchQueue.Attributes.concurrent)
    
    func update(_ x : [Double], prefix: String, image: UIImageView, imageFunc: @escaping (_ value1: String, _ value2: String, _ value3: String) -> (UIImage), label: UILabel) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
        let rt  = x.count == 0 ? "???" : Resistors.stringFrom(x[3])
        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
        UIView.animate(withDuration: 0.5) {
            image.image = imageFunc(r1v, r2v, r3v)
            label.text = "\(prefix) Total: \(rt); error: \(error)% with \(Resistors.active) resistors"
        }
    }
    
    func updateSeriesResistors (_ x : [Double], label: String) {
        update(x, prefix: label, image: seriesResistors, imageFunc: ResistorImage.imageOfSeriesResistors, label: seriesLabel)
//        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
//        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
//        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
//        let rt  = x.count == 0 ? "???" : Resistors.stringFrom(x[3])
//        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
//        UIView.animate(withDuration: 0.5) {
//            self.seriesResistors.image = ResistorImage.imageOfSeriesResistors(value1: r1v, value2: r2v, value3: r3v)
//            self.seriesLabel.text = "\(label) Total: \(rt); error: \(error)% with \(Resistors.active) resistors"
//        }
    }
    
    func updateSeriesParallelResistors (_ x : [Double], label: String) {
        update(x, prefix: label, image: seriesParallelResistors, imageFunc: ResistorImage.imageOfSeriesParallelResistors, label: seriesParallelLabel)
//        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
//        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
//        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
//        let rt  = x.count == 0 ? "???" : Resistors.stringFrom(x[3])
//        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
//        UIView.animate(withDuration: 0.5) {
//            self.seriesParallelResistors.image = ResistorImage.imageOfSeriesParallelResistors(value1: r1v, value2: r2v, value3: r3v)
//            self.seriesParallelLabel.text = "\(label) Total: \(rt); error: \(error)% with \(Resistors.active) resistors"
//        }
    }
    
    func updateParallelResistors (_ x : [Double], label: String) {
        update(x, prefix: label, image: parallelResistors, imageFunc: ResistorImage.imageOfParallelResistors, label: parallelLabel)
//        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
//        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
//        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
//        let rt  = x.count == 0 ? "???" : Resistors.stringFrom(x[3])
//        let error = x.count == 0 ? "???" : ResistorViewController.formatter.string(from: NSNumber(value: x[4]))!
//        UIView.animate(withDuration: 0.5) {
//            self.parallelResistors.image = ResistorImage.imageOfParallelResistors(value1: r1v, value2: r2v, value3: r3v)
//            self.parallelLabel.text = "\(label) Total: \(rt); error: \(error)% with \(Resistors.active) resistors"
//        }
    }
    
    func refreshGUI (_ x : [Double], y : [Double], z : [Double], label : String) {
        if calculating1 { updateSeriesResistors(x, label: label) }
        if calculating2 { updateSeriesParallelResistors(y, label: label) }
        if calculating3 { updateParallelResistors(z, label: label) }
    }
    
    static func takePDFOf(_ view: UIView) -> Data? {
        let renderer = UIGraphicsPDFRenderer(bounds: view.bounds)
        let data = renderer.pdfData { context in
            context.beginPage()
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        return data
    }
    
    static func takeSnapshotOf(_ view: UIView) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: view.frame.size.width, height: view.frame.size.height))
        view.drawHierarchy(in: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    @IBAction func sendResult(_ sender: Any) {
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
//            popoverController.sourceRect = sendReportButton.bounds
//            popoverController.sourceView = sendReportButton
        }
        present(x, animated: true, completion: nil)
    }
    
    func enableGUI () {
        let done = !calculating1 && !calculating2 && !calculating3
        var items = toolBar.items!
        if items.contains(actionButton) || items.contains(cancelButton) { items.removeLast() }
        if done {
            items.append(actionButton)
        } else {
            items.append(cancelButton)
        }
        toolBar.setItems(items, animated: true)
        desiredValue.isEnabled = done
        collectionButton.isEnabled = done
    }
    
    @IBAction func cancelCalculations(_ sender: Any) {
        print("Cancelled calculation")
        Resistors.cancelCalculations = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Resistors.initInventory()   // build up the values
        r = (10, 10, "Ω")
        calculateOptimalValues()
    }
    
    override func didReceiveMemoryWarning() {
        Resistors.clearInventory()
    }
    
    func stopTimer() {
        if !calculating1 && !calculating2 && !calculating3 {
            timedTask?.invalidate() // stop update timer if done
            timedTask = nil
        }
    }
    
    // make sure these variables are retained
    var r = (0.0, 0.0, "") {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.desiredValue.title = Resistors.stringFrom(self?.r.0 ?? 0)
            }
        }
    }
    var x = [Double]()
    var y = [Double]()
    var z = [Double]()
    var timedTask : Timer?
    var calculating1 = false
    var calculating2 = false
    var calculating3 = false
    
    func performCalculations(_ label : String, x : inout [Double], calculating : inout Bool, update : @escaping ([Double], String) -> (), activity : UIActivityIndicatorView) {
        calculating = true
        activity.startAnimating()
        backgroundQueue.async {
            print("Starting \(label) calculations...")
            Resistors.computeSeries(self.r.0, callback: { values in
                x = values   // update working values
            }, done: { s in
                x = s
                calculating = false
                self.stopTimer()
                DispatchQueue.main.async { [weak self] in
                    update(s, "Best")
                    activity.stopAnimating()
                    self?.enableGUI()
                    print("Finished \(label) calculations...")
                }
            })
        }
    }

    func calculateOptimalValues() {
        guard !(calculating1 || calculating2 || calculating3) else { print("ERROR!!!!!!"); return }
        Resistors.cancelCalculations = false
        timedTask = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.refreshGUI(self.x, y: self.y, z: self.z, label: "Working")
        }
        timedTask?.fire()     // refresh GUI to start
        
        performCalculations("series", x: &x, calculating: &calculating1, update: updateSeriesResistors(_:label:), activity: seriesActivity)
        
//        backgroundQueue.async {
//            print("Starting series calculations...")
//            Resistors.computeSeries(self.r.0, callback: { values in
//                self.x = values   // update working values
//            }, done: { s in
//                self.x = s
//                self.calculating1 = false
//                self.stopTimer()
//                DispatchQueue.main.async { [weak self] in
//                    self?.updateSeriesResistors(s, label: "Best")
//                    self?.seriesActivity.stopAnimating()
//                    self?.enableGUI()
//                    print("Finished series calculations...")
//                }
//            })
//        }
        
        performCalculations("series/parallel", x: &y, calculating: &calculating2, update: updateSeriesParallelResistors(_:label:), activity: seriesParallelActivity)
        
//        backgroundQueue.async {
//            print("Starting series/parallel calculations...")
//            Resistors.computeSeriesParallel(self.r.0, callback: { values in
//                self.y = values   // update working values
//            }, done: { sp in
//                self.y = sp        // final answer update
//                self.calculating2 = false
//                self.stopTimer()
//                DispatchQueue.main.async { [weak self] in
//                    self?.updateSeriesParallelResistors(sp, label: "Best")
//                    self?.seriesParallelActivity.stopAnimating()
//                    self?.enableGUI()
//                    print("Finished series/parallel calculations...")
//                }
//            })
//        }
        
        performCalculations("parallel", x: &z, calculating: &calculating3, update: updateParallelResistors(_:label:), activity: parallelActivity)
        
//        backgroundQueue.async {
//            print("Starting parallel calculations...")
//            Resistors.computeParallel(self.r.0, callback: { values in
//                self.z = values   // update working values
//            }, done: { p in
//                self.z = p        // final answer update
//                print("Parallel answer = \(p)")
//                self.calculating3 = false
//                self.stopTimer()
//                DispatchQueue.main.async { [weak self] in
//                    self?.updateParallelResistors(p, label: "Best")
//                    self?.parallelActivity.stopAnimating()
//                    self?.enableGUI()
//                    print("Finished parallel calculations...")
//                }
//            })
//        }
        enableGUI()
    }
    
    @IBAction func editingDidBegin(_ sender: UITextField) {
        performSegue(withIdentifier: "PresentPicker", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destNav = segue.destination
        let popPC = destNav.popoverPresentationController
        popPC?.delegate = self
        switch segue.identifier! {
        case "SelectResistance":
            if let vc = destNav.childViewControllers.first as? ResistancePickerViewController {
                vc.value = desiredValue.title
                vc.callback = { [weak self] newValue in
                    guard let wself = self else { return }
                    wself.r = Resistors.parseString(newValue)
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

extension ResistorViewController : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // allows popover to appear for iPhone-style devices
        return .none
    }
    
}

