//
//  ResistorViewMController.swift
//  Resistor Box Mac
//
//  Created by Michael Griebling on 2018-03-12.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import Cocoa

class ResistorViewMController: NSViewController {
    
    @IBOutlet weak var desiredValue: NSTextField!
    @IBOutlet weak var ohmsSelector: NSComboBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        desiredValue.stringValue = "10"
        ohmsSelector.selectItem(at: 1)
    }
    
    @IBAction func calculateDesiredValue(_ sender: NSTextField) {
        print("Calculating values...")
    }
}
