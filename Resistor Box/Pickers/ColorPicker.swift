
import UIKit

class ColorPicker: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    typealias ColorChanged = (_ picker: ColorPicker) -> ()
    
    var colors : [String: UIColor] = [
        "Color 01"  : UIColor(hue: 0.00000, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 02"  : UIColor(hue: 0.05263, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 03"  : UIColor(hue: 0.10526, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 04"  : UIColor(hue: 0.15789, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 05"  : UIColor(hue: 0.21052, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 06"  : UIColor(hue: 0.26316, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 07"  : UIColor(hue: 0.31579, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 08"  : UIColor(hue: 0.36842, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 09"  : UIColor(hue: 0.42105, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 10"  : UIColor(hue: 0.47368, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 11"  : UIColor(hue: 0.52632, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 12"  : UIColor(hue: 0.57895, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 13"  : UIColor(hue: 0.63158, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 14"  : UIColor(hue: 0.68421, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 15"  : UIColor(hue: 0.73684, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 16"  : UIColor(hue: 0.78947, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 17"  : UIColor(hue: 0.84211, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 18"  : UIColor(hue: 0.89474, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 19"  : UIColor(hue: 0.94737, saturation: 0.7, brightness: 1, alpha: 1),
        "Color 20"  : UIColor(hue: 1.00000, saturation: 0.7, brightness: 1, alpha: 1)
    ]
    
    var selectedColor: String
    var valueChangeCallback: ColorChanged = { (picker) -> () in }
    
    init (_ color: String) {
        selectedColor = color
    }
    
    func setPicker(_ picker: UIPickerView, toCurrentValue value: String) {
        if let index = colors.keys.sorted().index(of: value) {
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
        selectedColor = colors.keys.sorted()[row]
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
        return colors.count
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
        let key = colors.keys.sorted()[row]
        newView.label = key
        newView.color = colors[key]!
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
