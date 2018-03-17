
import UIKit

/**
 
     Class to implement a graphical collection picker control.  The
     *valueChangeCallback* is called whenever the user selects a new collection.
     The active collection string is saved in *selectedCollection*.
     
     - Author:  Michael Griebling
     - Date:    8 Sep 2015
 
 ******************************************************************************** */

class CollectionPicker: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    typealias CollectionChanged = (_ picker: CollectionPicker) -> ()
    
    var selectedCollection: String
    var valueChangeCallback: CollectionChanged = { (picker) -> () in }
    
    var collection : [String]   // what to display in the scroller
    
    //********************************************************************************
    /**
       Collection picker initialization method.
     
        - Author:   Michael Griebling
        - Date:   	15 July 2013
     
     ******************************************************************************** */
    init (_ selected : String, items : [String]) {
        if let _ = items.index(of: selected) {
            selectedCollection = selected
        } else {
            selectedCollection = ""
        }
        collection = items
    }
    
    //********************************************************************************
    /**
       Sets the *picker* to the current *collection*.
     
        - Author:   Michael Griebling
        - Date:   	15 July 2013
     
     ******************************************************************************** */
    func setPicker(_ picker: UIPickerView, toCurrentValue value: String) {
        if let index = collection.index(of:value) {
            selectedCollection = value
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
        selectedCollection = collection[row]
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
        return collection.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return collection[row]
    }
    
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        var loggerView = view as? LoggerView
//        if view == nil {
//            let subViewArray = Bundle.main.loadNibNamed("LoggerView", owner:self, options:nil)
//            loggerView = subViewArray?[0] as? LoggerView
//        }
//
//        loggerView!.loggerImage!.image = CollectionPicker.loggerImages[row]
//        loggerView!.loggerImage!.contentMode = UIViewContentMode.scaleAspectFit
//        loggerView!.loggerName!.text = CollectionPicker.loggerNames[row]
//        return loggerView!
//    }
    
//    //********************************************************************************
//    /**
//       Picker delegate method to return the height of rows in the
//              *component* scroll wheel.
//
//        - Author:   Michael Griebling
//        - Date:       15 July 2013
//
//     ******************************************************************************** */
//    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
//        return 89
//    }
//
//    //********************************************************************************
//    /**
//       Picker delegate method to return the width of the *component* scroll
//              wheel.
//
//        - Author:   Michael Griebling
//        - Date:       15 July 2013
//
//     ******************************************************************************** */
//    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        return pickerView.frame.size.width - 30
//    }
    
}
