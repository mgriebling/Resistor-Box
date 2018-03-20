//
//  FirstViewController.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-02-15.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class ResistorViewController: BaseViewController {

    @IBOutlet weak var seriesResistors: UIImageView!
    @IBOutlet weak var seriesLabel: UILabel!
    @IBOutlet weak var seriesActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var seriesParallelResistors: UIImageView!
    @IBOutlet weak var seriesParallelLabel: UILabel!
    @IBOutlet weak var seriesParallelActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var parallelResistors: UIImageView!
    @IBOutlet weak var parallelLabel: UILabel!
    @IBOutlet weak var parallelActivity: UIActivityIndicatorView!
    
    func updateSeriesResistors (_ x : [Double], label: String) {
        update(x, prefix: label, image: seriesResistors, imageFunc: ResistorImage.imageOfSeriesResistors, label: seriesLabel)
    }
    
    func updateSeriesParallelResistors (_ x : [Double], label: String) {
        update(x, prefix: label, image: seriesParallelResistors, imageFunc: ResistorImage.imageOfSeriesParallelResistors, label: seriesParallelLabel)
    }
    
    func updateParallelResistors (_ x : [Double], label: String) {
        update(x, prefix: label, image: parallelResistors, imageFunc: ResistorImage.imageOfParallelResistors, label: parallelLabel)
    }
    
    func refreshGUI (_ x : [Double], y : [Double], z : [Double], label : String) {
        if calculating1 { updateSeriesResistors(x, label: label) }
        if calculating2 { updateSeriesParallelResistors(y, label: label) }
        if calculating3 { updateParallelResistors(z, label: label) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        r = (10, 10, "Ω")
        calculateOptimalValues()
    }
    
    // make sure these variables are retained
    var r = (0.0, 0.0, "") {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.desiredValue.title = Resistors.stringFrom(self?.r.0 ?? 0)
            }
        }
    }

    func calculateOptimalValues() {
        guard !(calculating1 || calculating2 || calculating3) else { print("ERROR!!!!!!"); return }
        Resistors.cancelCalculations = false
        timedTask = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.refreshGUI(self.x, y: self.y, z: self.z, label: "Working")
        }
        timedTask?.fire()     // refresh GUI to start
        
        performCalculations("series", r: r.0, x: &x, compute: Resistors.computeSeries(_:callback:done:), calculating: &calculating1,
                            update: updateSeriesResistors(_:label:), activity: seriesActivity)
        performCalculations("series/parallel", r: r.0, x: &y, compute: Resistors.computeSeriesParallel(_:callback:done:), calculating: &calculating2,
                            update: updateSeriesParallelResistors(_:label:), activity: seriesParallelActivity)
        performCalculations("parallel", r: r.0, x: &z, compute: Resistors.computeParallel(_:callback:done:), calculating: &calculating3,
                            update: updateParallelResistors(_:label:), activity: parallelActivity)
        
        enableGUI()
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

