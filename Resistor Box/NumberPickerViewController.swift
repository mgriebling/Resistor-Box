//
//  NumberPickerViewController.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-03-06.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class NumberPickerViewController: UIViewController {

    @IBOutlet weak var pickerView: UIPickerView!
    
    var picker = NumberPicker(maximum: Decimal(string: "999.999")!, andIncrement: Decimal(string: "1000.0")!, andLabels: ["mΩ", "Ω", "KΩ", "MΩ"])
    
    public var value : String?
    public var callback : (String) -> () = { arg in }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pickerView.delegate = picker
        pickerView.dataSource = picker
        let r = Resistors.parseString(value ?? "0Ω")
        picker.set(pickerView, toCurrentValue: Decimal(r.0), label: r.1)
        picker.valueChangeCallback = { [weak self] picker in
            guard let wself = self else { return }
            let unit = picker.getSelectedLabel(picker: wself.pickerView)
            let value = picker.value
            let rvalue = "\(value)\(unit)"
            wself.callback(rvalue)
            print("Set picker to \(rvalue)")
        }
    }

}
