//
//  BaseViewController.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-03-19.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    @IBOutlet var preferencesMenu: UIBarButtonItem!
    @IBOutlet weak var desiredValue: UIBarButtonItem!
    @IBOutlet var minResistance: UIBarButtonItem!
    @IBOutlet var stopButton: UIBarButtonItem!
    @IBOutlet var actionButton: UIBarButtonItem!
    @IBOutlet weak var collectionButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    weak var popover : UIPopoverPresentationController?     // use to hold popover to assist rotations
    static var activeTab : Int?
    
    var minR = (10_000.0, 10.0, "KΩ") {
        didSet {
            minResistance?.title = ">" + Resistors.stringFrom(minR.0)
        }
    }
    
    @IBAction func userPreferences(_ sender: Any) {
        BaseViewController.activeTab = tabBarController?.selectedIndex
        cancelCalculations(self)
    }
    
    @IBAction func cancelCalculations(_ sender: Any) {
        print("Cancelled calculation")
        Resistors.cancelCalculations = true
        DispatchQueue.main.async { [weak self] in
            self?.enableGUI()
        }
    }
    
    static private var formatter : NumberFormatter {
        let f = NumberFormatter()
        f.maximumFractionDigits = 6
        f.minimumIntegerDigits = 1
        return f
    }
    
    func stringFrom (_ number: Double) -> String {
        return BaseViewController.formatter.string(from: NSNumber(value: number)) ?? "0"
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
    
    @IBAction func returnToResistorView(_ segue: UIStoryboardSegue?) {
        popover = nil
        
        // restore the active tab if the user swipped to the preferences
        if let active = BaseViewController.activeTab {
            DispatchQueue.main.async { [weak self] in
                self?.tabBarController?.selectedIndex = active  // back to original selected tab
            }
            BaseViewController.activeTab = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Resistors.initInventory()   // build up the values
        
        // set up gesture recognizer
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGestureRecognizer.direction = .up
        swipeGestureRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    func refreshGUI (_ x : [Double], y : [Double], z : [Double], label : String) {
    }
    
    func calculateOptimalValues() {
        guard !(calculating1 || calculating2 || calculating3) else { print("ERROR!!!!!!"); return }
        Resistors.cancelCalculations = false
        timedTask = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.refreshGUI(self.x, y: self.y, z: self.z, label: "Working")
        }
        timedTask?.fire()     // refresh GUI to start
    }
    
    deinit {
        // not sure if this is still necessary?
        if let recognizer = view.gestureRecognizers?.first {
            view.removeGestureRecognizer(recognizer)
        }
    }
    
    @objc public func handleSwipe(_ recognizer: UISwipeGestureRecognizer) {
        BaseViewController.activeTab = tabBarController?.selectedIndex
        cancelCalculations(self)
        performSegue(withIdentifier: "UserSettings", sender: self)
    }
    
    public func refreshAll() {
        // child needs to override this
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // update tab graphics
        if let tbc = tabBarController, let items = tbc.tabBar.items {
            items.first!.image = UIImage(named: preferences.useEuroSymbols ? "EResistor" : "Resistor")
            items.first!.selectedImage = UIImage(named: preferences.useEuroSymbols ? "EResistor" : "Resistor")
            items[2].image = UIImage(named: preferences.useEuroSymbols ? "EDivider" : "Divider")
            items[2].selectedImage = UIImage(named: preferences.useEuroSymbols ? "EDivider" : "Divider")
        }
        collectionButton?.title = Resistors.active
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
    
    var isPhone : Bool {
        let isPortrait = UIDevice.current.orientation.isPortrait
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        return isPortrait && isPhone
    }
    
    func enableGUI () {
        let done = !calculating1 && !calculating2 && !calculating3
        var items = toolBar.items!
        if items.contains(actionButton) { items.removeLast() }
        if let stop = stopButton, items.contains(stop) { items.removeLast() }
        if let r = minResistance, let index = items.index(of: r) { items.remove(at: index) }
//        if isPhone {
        if items.contains(preferencesMenu) { items.removeFirst() }
//        } else {
//            if !items.contains(preferencesMenu) { items.insert(preferencesMenu, at: 0) }
//        }
        if done {
            if let minR = minResistance, let index = items.index(of: collectionButton) {
                items.insert(minR, at: index+1)
            }
            if !items.contains(preferencesMenu) { items.insert(preferencesMenu, at: 0) }
            items.append(actionButton)
        } else if stopButton != nil {
            items.append(stopButton)
        }
        toolBar.setItems(items, animated: true)
        desiredValue.isEnabled = done
        collectionButton?.isEnabled = done
        minResistance?.isEnabled = done
        preferencesMenu?.isEnabled = done
    }
    
    func formatValue(_ x : Double) -> String {
        // stub to be overridden
        assert(false, "Need to override 'formatValue' method")
        return "Value: \(x)"
    }
    
    func update(_ x : [Double], prefix: String, image: UIImageView, color: UIColor, imageFunc: @escaping (UIColor, String, String, String, String) -> (UIImage)) {
        let r1v = x.count == 0 ? "???" : Resistors.stringFrom(x[0])
        let r2v = x.count == 0 ? "???" : Resistors.stringFrom(x[1])
        let r3v = x.count == 0 ? "???" : Resistors.stringFrom(x[2])
        let rt  = x.count == 0 ? "???" : formatValue(x[3])
        let error = x.count == 0 ? "???" : BaseViewController.formatter.string(from: NSNumber(value: x[4]))!
        DispatchQueue.main.async { 
            UIView.animate(withDuration: 0.5) {
                let label = "\(prefix) \(rt); error: \(error)% with \(Resistors.active) resistors"
                image.image = imageFunc(color, r1v, r2v, r3v, label)
            }
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
            }, { [weak self] fvalues in
                x = fvalues
                calculating = false
                self?.stopTimer()
                DispatchQueue.main.async { [weak self] in
                    update(fvalues, "Best")
                    activity.stopAnimating()
                    self?.enableGUI()
                    print("Finished \(label) calculations...")
                }
            })
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            if let pover = self.popover {
                if let button = pover.sourceView as? UIButton {
                    button.setNeedsLayout()
                    button.layoutIfNeeded()
                }
            }
        }, completion: nil)
    }
    
}

extension BaseViewController : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // allows popover to appear for iPhone-style devices
        return .none
    }
    
}
