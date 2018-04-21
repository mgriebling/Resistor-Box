

import UIKit

public typealias Color = UIColor   // needed for generic user preferences

class ColorPickerViewController: UIViewController {
	
    @IBOutlet weak var pickerView: UIPickerView! {
        didSet {
            pickerView.dataSource = colorPicker
            pickerView.delegate = colorPicker
        }
    }
    
    // Global variables
    let colorPicker = ColorPicker("Silver")
    public var callback : (String, UIColor) -> () = { name, arg in }
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        colorPicker.setPicker(pickerView, toCurrentValue: colorPicker.selectedColor)
        colorPicker.valueChangeCallback = { [weak self] picker in
            let value = picker.selectedColor
            let color = Store.colors[value]!
            self?.callback(value, color)
        }
    }
    
}
