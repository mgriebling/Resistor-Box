
import UIKit

class ColorPicker: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    typealias ColorChanged = (_ picker: ColorPicker) -> ()
    
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
        return 65
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
