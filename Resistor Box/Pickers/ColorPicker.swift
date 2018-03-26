
import UIKit

class ColorPicker: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    typealias ColorChanged = (_ picker: ColorPicker) -> ()
    
    static public let colors : [String: UIColor] = [
        "Silver"     : UIColor(hue: 148/360.0, saturation: 0.00, brightness: 0.84, alpha: 1),
        "Snow"       : UIColor(hue: 180/360.0, saturation: 0.00, brightness: 1.00, alpha: 1),
        "Salmon"     : UIColor(hue:   2/360.0, saturation: 0.53, brightness: 1.00, alpha: 1),
        "Cantaloupe" : UIColor(hue:  41/360.0, saturation: 0.53, brightness: 1.00, alpha: 1),
        "Banana"     : UIColor(hue:  59/360.0, saturation: 0.53, brightness: 1.00, alpha: 1),
        "Honeydew"   : UIColor(hue:  78/360.0, saturation: 0.52, brightness: 0.99, alpha: 1),
        "Flora"      : UIColor(hue: 123/360.0, saturation: 0.54, brightness: 0.98, alpha: 1),
        "Spindrift"  : UIColor(hue: 163/360.0, saturation: 0.54, brightness: 0.99, alpha: 1),
        "Ice"        : UIColor(hue: 181/360.0, saturation: 0.55, brightness: 1.00, alpha: 1),
        "Sky"        : UIColor(hue: 198/360.0, saturation: 0.54, brightness: 1.00, alpha: 1),
        "Orchid"     : UIColor(hue: 237/360.0, saturation: 0.52, brightness: 1.00, alpha: 1),
        "Lavender"   : UIColor(hue: 281/360.0, saturation: 0.49, brightness: 1.00, alpha: 1),
        "Bubblegum"  : UIColor(hue: 300/360.0, saturation: 0.48, brightness: 1.00, alpha: 1),
        "Carnation"  : UIColor(hue: 320/360.0, saturation: 0.46, brightness: 1.00, alpha: 1),
        "Maraschino" : UIColor(hue:   9/360.0, saturation: 1.00, brightness: 1.00, alpha: 1),
        "Lemon"      : UIColor(hue:  59/360.0, saturation: 1.00, brightness: 1.00, alpha: 1),
        "Spring"     : UIColor(hue: 120/360.0, saturation: 1.00, brightness: 0.98, alpha: 1),
        "Aqua"       : UIColor(hue: 205/360.0, saturation: 1.00, brightness: 1.00, alpha: 1),
        "Blueberry"  : UIColor(hue: 229/360.0, saturation: 0.98, brightness: 1.00, alpha: 1),
        "Strawberry" : UIColor(hue: 331/360.0, saturation: 0.81, brightness: 1.00, alpha: 1)
    ]
    
    var selectedColor: String = "Silver"
    var valueChangeCallback: ColorChanged = { (picker) -> () in }
    
    init (_ color: String) {
        if let _ = ColorPicker.colors.keys.sorted().index(of: color) {
            selectedColor = color
        }
    }
    
    func setPicker(_ picker: UIPickerView, toCurrentValue value: String) {
        if let index = ColorPicker.colors.keys.sorted().index(of: value) {
            selectedColor = value
            picker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    // MARK: - UIPickerViewDelegate/Datasource
    
    //********************************************************************************
    /**
       Implements the picker view call-back and setting the selected logger.
     
        - Author:   Michael Griebling
        - Date:   	15 July 2013
     
     ******************************************************************************** */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedColor = ColorPicker.colors.keys.sorted()[row]
        valueChangeCallback(self)
    }
    
    //********************************************************************************
    /**
       Picker delegate method to return the number of scroll wheels.
     
        - Author:   Michael Griebling
        - Date:   	15 July 2013
     
     ******************************************************************************** */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //********************************************************************************
    /**
       Picker delegate method to return the number of picker values.
     
        - Author:   Michael Griebling
        - Date:   	15 July 2013
     
     ******************************************************************************** */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ColorPicker.colors.count
    }
    
    //********************************************************************************
    /**
       Picker delegate method to return a view containing a logger with an
              identifying sub-title.
     
        - Author:   Michael Griebling
        - Date:   	15 July 2013
     
     ******************************************************************************** */
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var newView : ColorView
        if  let colorView = view as? ColorView {
            newView = colorView
        } else {
            newView = ColorView()
        }
        let key = ColorPicker.colors.keys.sorted()[row]
        newView.label = key
        newView.color = ColorPicker.colors[key]!
        return newView
    }
    
    //********************************************************************************
    /**
       Picker delegate method to return the height of rows in the
              *component* scroll wheel.
     
        - Author:   Michael Griebling
        - Date:   	15 July 2013
     
     ******************************************************************************** */
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    //********************************************************************************
    /**
       Picker delegate method to return the width of the *component* scroll
              wheel.
     
        - Author:   Michael Griebling
        - Date:   	15 July 2013
     
     ******************************************************************************** */
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width - 20
    }
    
}
