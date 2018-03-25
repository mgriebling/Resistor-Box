//
//  BaseViewController.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-03-19.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    @IBOutlet weak var desiredValue: UIBarButtonItem!
    @IBOutlet weak var minResistance: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var collectionButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBAction func cancelCalculations(_ sender: Any) {
        print("Cancelled calculation")
        Resistors.cancelCalculations = true
    }
    
    static var formatter : NumberFormatter {
        let f = NumberFormatter()
        f.maximumFractionDigits = 6
        f.minimumIntegerDigits = 1
        return f
    }
    
    var x = [Double]()
    var y = [Double]()
    var z = [Double]()
    var timedTask : Timer?
    var calculating1 = false
    var calculating2 = false
    var calculating3 = false
    
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
    
    let backgroundQueue = DispatchQueue(label: "com.c-inspirations.resistorBox.bgqueue", qos: .background, attributes: DispatchQueue.Attributes.concurrent)
    
    @IBAction func returnToResistorView(_ segue: UIStoryboardSegue?) {  }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Resistors.initInventory()   // build up the values
    }
    
    public func refreshAll() {
        // child needs to override this
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshAll()  // user may have changed preferences
    }
    
    override func didReceiveMemoryWarning() {
        Resistors.clearInventory()
    }
    
    @IBAction func sendResult(_ sender: Any) {
        print("Sending result...")
        let graphic = BaseViewController.takeSnapshotOf(self.parent!.view)!
        
        let pdf = BaseViewController.takePDFOf(self.parent!.view)
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
    
    func stopTimer() {
        if !calculating1 && !calculating2 && !calculating3 {
            timedTask?.invalidate() // stop update timer if done
            timedTask = nil
        }
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
        minResistance?.isEnabled = done
    }
    
    func formatValue(_ x : Double) -> String {
        // stub to be overridden
        assert(false, "Need to override 'formatValue' method")
        return "Value: \(x)"
    }
    
    func update(_ x : [Double], prefix: String, image: UIImageView,
                imageFunc: @escaping (String, String, String) -> (UIImage), label: UILabel) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
        let rt  = x.count == 0 ? "???" : formatValue(x[3])
        let error = x.count == 0 ? "???" : BaseViewController.formatter.string(from: NSNumber(value: x[4]))!
        UIView.animate(withDuration: 0.5) {
            image.image = imageFunc(r1v, r2v, r3v)
            label.text = "\(prefix) \(rt); error: \(error)% with \(Resistors.active) resistors"
        }
    }
    
    func update(_ x : [Double], prefix: String, image: UIImageView, imageFunc: @escaping (String, String, String, String) -> (UIImage)) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
        let rt  = x.count == 0 ? "???" : formatValue(x[3])
        let error = x.count == 0 ? "???" : BaseViewController.formatter.string(from: NSNumber(value: x[4]))!
        UIView.animate(withDuration: 0.5) {
            let label = "\(prefix) \(rt); error: \(error)% with \(Resistors.active) resistors"
            image.image = imageFunc(r1v, r2v, r3v, label)
        }
    }
    
    func performCalculations(_ label : String, value : Double, start: Double, x : inout [Double],
                             compute : @escaping (Double, Double, ([Double]) -> (), ([Double]) -> ()) -> (),
                             calculating : inout Bool, update : @escaping ([Double], String) -> (), activity : UIActivityIndicatorView) {
        calculating = true
        activity.startAnimating()
        backgroundQueue.async {
            print("Starting \(label) calculations...")
            compute(value, start, { values in
                x = values   // update working values
            }, { fvalues in
                x = fvalues
                calculating = false
                self.stopTimer()
                DispatchQueue.main.async { [weak self] in
                    update(fvalues, "Best")
                    activity.stopAnimating()
                    self?.enableGUI()
                    print("Finished \(label) calculations...")
                }
            })
        }
    }
}

extension BaseViewController : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // allows popover to appear for iPhone-style devices
        return .none
    }
    
}
