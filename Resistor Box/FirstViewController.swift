//
//  FirstViewController.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-02-15.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var seriesResistors: UIImageView! {
        didSet {
            seriesResistors.image = ResistorImage.imageOfSeriesResistors(value1: "???", value2: "???", valu3: "???")
        }
    }
    @IBOutlet weak var seriesLabel: UILabel!
    
    @IBOutlet weak var seriesParallelResistors: UIImageView!  {
        didSet {
            seriesParallelResistors.image = ResistorImage.imageOfSeriesParallelResistors(value1: "???", value2: "???", valu3: "???")
        }
    }
    @IBOutlet weak var seriesParallelLabel: UILabel!
    
    @IBOutlet weak var parallelResistors: UIImageView! {
        didSet {
            parallelResistors.image = ResistorImage.imageOfParallelResistors(value1: "???", value2: "???", valu3: "???")
        }
    }
    @IBOutlet weak var parallelLabel: UILabel!
    
    func updateSeriesResistors (_ error: Double, r1: Double, r2: Double, r3: Double) {
        let r1v = Resistors.stringFrom(r1)
        let r2v = Resistors.stringFrom(r2)
        let r3v = Resistors.stringFrom(r3)
        let rt = Resistors.stringFrom(r1+r2+r3)
        DispatchQueue.main.async {
            self.seriesResistors.image = ResistorImage.imageOfSeriesResistors(value1: r1v, value2: r2v, valu3: r3v)
            self.seriesLabel.text = "Best result: \(rt); error: \(error)% with 1% resistors"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        DispatchQueue.global().async {
            let x = Resistors.computeSeries(100.2) { (error, r1, r2, r3) in
                self.updateSeriesResistors(error, r1:r1, r2: r2, r3: r3)
            }
            print(x)
            self.updateSeriesResistors(x[4], r1: x[0], r2: x[1], r3: x[2])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

