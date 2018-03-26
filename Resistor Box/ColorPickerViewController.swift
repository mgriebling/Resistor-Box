

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
	var color: UIColor = UIColor.gray
    var colorPicker = ColorPicker("Light Grey")
    public var callback : (String, UIColor) -> () = { name, arg in }
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        colorPicker.valueChangeCallback = { [weak self] picker in
            let value = picker.selectedColor
            let color = picker.colors[value]!
            self?.callback(value, color)
            print("Changed color to \(value)")
        }
    }
    
}
