//
//  NumberPickerViewController.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-03-16.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class NumberPickerViewController: UIViewController {

    @IBOutlet weak var pickerView: UIPickerView!
    
    var picker = NumberPicker(maxValue: Decimal(string: "999.999")!, andIncrement: Decimal(string: "1000.0")!)
    
    public var value : String?
    public var callback : (String) -> () = { arg in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        pickerView.delegate = picker
        pickerView.dataSource = picker
        let r = Double(value ?? "0") ?? 0
        
        // normalize the value
        picker.set(pickerView, toCurrentValue: Decimal(r))
        picker.valueChangeCallback = { [weak self] picker in
            guard let wself = self else { return }
            wself.value = "\(picker.value)"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        value = "\(picker.value)"
        callback(value!)
        super.viewWillDisappear(animated)
    }

}
