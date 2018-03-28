//
//  ResistorViewController.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-02-15.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class ResistorViewController: BaseViewController {

    @IBOutlet weak var seriesResistors: UIImageView!
    @IBOutlet weak var seriesActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var seriesParallelResistors: UIImageView!
    @IBOutlet weak var seriesParallelActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var parallelResistors: UIImageView!
    @IBOutlet weak var parallelActivity: UIActivityIndicatorView!
    
    func updateSeriesResistors (_ x : [Double], label: String) {
        let color = ColorPicker.colors[preferences.color1]!
        update(x, prefix: label, image: seriesResistors, color: color, imageFunc: ResistorImage.imageOfSeriesResistors)
    }
    
    func updateSeriesParallelResistors (_ x : [Double], label: String) {
        let color = ColorPicker.colors[preferences.color2]!
        update(x, prefix: label, image: seriesParallelResistors, color: color, imageFunc: ResistorImage.imageOfSeriesParallelResistors)
    }
    
    func updateParallelResistors (_ x : [Double], label: String) {
        let color = ColorPicker.colors[preferences.color3]!
        update(x, prefix: label, image: parallelResistors, color: color, imageFunc: ResistorImage.imageOfParallelResistors)
    }
    
    func refreshGUI (_ x : [Double], y : [Double], z : [Double], label : String) {
        if calculating1 { updateSeriesResistors(x, label: label) }
        if calculating2 { updateSeriesParallelResistors(y, label: label) }
        if calculating3 { updateParallelResistors(z, label: label) }
    }
    
    override func refreshAll() {
        super.refreshAll()
        let label = "Best"
        updateSeriesResistors(x, label: label)
        updateSeriesParallelResistors(y, label: label)
        updateParallelResistors(z, label: label)
    }
    
    override func formatValue(_ x: Double) -> String {
        return "Total: " + Resistors.stringFrom(x)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateOptimalValues()
    }
    
    // make sure these variables are retained
    var r = (10.0, 10.0, "Ω") {
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
        
        performCalculations("series", value: r.0, start: 0, x: &x, compute: Resistors.computeSeries(_:start:callback:done:), calculating: &calculating1,
                            update: updateSeriesResistors(_:label:), activity: seriesActivity)
        performCalculations("series/parallel", value: r.0, start: 0, x: &y, compute: Resistors.computeSeriesParallel(_:start:callback:done:), calculating: &calculating2,
                            update: updateSeriesParallelResistors(_:label:), activity: seriesParallelActivity)
        performCalculations("parallel", value: r.0, start: 0, x: &z, compute: Resistors.computeParallel(_:start:callback:done:), calculating: &calculating3,
                            update: updateParallelResistors(_:label:), activity: parallelActivity)
        enableGUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destNav = segue.destination
        let popPC = destNav.popoverPresentationController
        popover = popPC
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


