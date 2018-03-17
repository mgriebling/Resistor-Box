//
//  CollectionViewController.swift
//  Resistor Box
//
//  Created by Mike Griebling on 17 Mar 2018.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController {

    @IBOutlet weak var pickerView: UIPickerView!
    
    var picker = CollectionPicker(Resistors.active, items: Resistors.rInv.keys.sorted())
    
    public var value : String?
    public var callback : (String) -> () = { arg in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        pickerView.delegate = picker
        pickerView.dataSource = picker
        let value = Resistors.active
        
        // normalize the value
        picker.setPicker(pickerView, toCurrentValue: value)
        picker.valueChangeCallback = { [weak self] picker in
            guard let wself = self else { return }
            wself.value = picker.selectedCollection
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        value = picker.selectedCollection
        callback(value!)
        super.viewWillDisappear(animated)
    }

}
