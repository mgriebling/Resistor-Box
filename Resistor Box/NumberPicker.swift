
import Foundation

//********************************************************************************
//
// This source is Copyright (c) 2016 by Solinst Canada.  All rights reserved.
//
//********************************************************************************
/**
     Implementation of a scroll-wheel style picker displaying a number that can
     be edited using digit-by-digit scroll wheels.  The *NumberPicker* handles
     three kinds of numbers:
 
       * Minimum/maximum number pickers where all numbers within the *minValue* /
         *maxValue* range with a given *stepSize* are selectable.
       * Normal number pickers where all digits are selectable.  The number of
         digits is defined by an initializer argument like *9.999*.
       * Rate picker where time intervals such as seconds, minutes, etc. can
         selected via a picker.  The rate picker takes a *Rate* as an agument.
     
     - Author:  Michael Griebling
     - Date:    29 Sep 2016
 
 ******************************************************************************** */

class NumberPicker: NSObject, PickerViewDataSource, PickerViewDelegate {

    typealias ValueChanged = (_ picker: NumberPicker) -> ()
    
    enum NumberPickerType { case minMax, number, rate }

    var maxValue: Decimal = 0
    var minValue: Decimal = 0
    var stepSize: Decimal = 0
//    var rate: Rate?
    var valueChangeCallback: ValueChanged?
    
    // MARK: - Getters/setters

    //********************************************************************************
    /**
       Getter for the *columnValues* property.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    var columnValues : [[String]] { return _columnValues }
    
    //********************************************************************************
    /**
       Setter for the *decimalColumn* property.  Also sets the initial
               value for *maxActiveRow*.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    var decimalColumn : Int = -1 {
        didSet {
            maxActiveRow = decimalColumn
        }
    }
    
    //********************************************************************************
    /**
       Setter for the *value* property.  This method implements a callback
               using *valueChangeCallback* so the user can monitor changes to an
               associated number picker.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    var value : Decimal = 0 {
        didSet { valueChangeCallback?(self) }
    }
    
    //********************************************************************************
    /**
       Return *true* if the active number is negative.
     
       - Author:  Michael Griebling
       - Date:    1 October 2013
     
     ******************************************************************************** */
    var isNegativeNumber : Bool { return value.isSignMinus }
    
    private var _columnValues : [[String]] = []
    private var negativeColumnValues : [[String]] = []
    private var labels : [String] = []
    private var maxActiveRow : Int = 0
    private var kindOfPicker : NumberPickerType = .number
    
    //********************************************************************************
    /**
       Getter for the number formatter.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    private lazy var formatter : NumberFormatter? = {
        let _formatter = NumberFormatter()
        _formatter.formatterBehavior = .behavior10_4
        _formatter.numberStyle = .decimal
        _formatter.generatesDecimalNumbers = true
        return _formatter
    }()
    
    //********************************************************************************
    /**
       Internal method to return the number of columns in the picker -- while
               ignoring any labels.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    private func getNumberColumnCount() -> Int {
        let columns = !isNegativeNumber ? columnValues : negativeColumnValues
        var numberColumns = columns.count
        if labels.count > 0 { numberColumns -= 1 }
        if negativeColumnValues.count > 0 { numberColumns += 1 }
        return numberColumns
    }
    
    //********************************************************************************
    /**
       Returns a string representation of the active picker selections.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    func getPickerNumberAsString(picker: PickerView) -> String {
        var val = ""
        let columns = getNumberColumnCount()
        
        for i in 0..<columns {
            if i < picker.numberOfComponents {
                var selected = picker.selectedRow(inComponent: i)
                if negativeColumnValues.count > 0 {
                    if i == 0 {
                        if selected == 1 { val += "-" }
                        continue   // next loop iteration
                    } else {
                        selected = picker.selectedRow(inComponent:i+1)
                    }
                }
                if i == decimalColumn { val += ".\(selected)" }
                else { val += "\(selected)" }
            }
        }
        return val
    }
    
    //********************************************************************************
    /**
       Internal method to split a number string into separate character-sized pieces.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    private func splitStringToArray(_ stringVal: String) -> [String] {
        var splitVal : [String] = []
        let locale = NSLocale.current
        let dp = locale.decimalSeparator
        
        var i = 0
        while i < stringVal.count {
            var numStr = "\(stringVal[i])"  //[NSString stringWithFormat:@"%c", stringVal.cha characterAtIndex:i]];
            if numStr == dp {
                if decimalColumn == -1 { decimalColumn = i }
                numStr = "\(stringVal[i+1])"
                i += 1
            }
            splitVal.append(numStr) // addObject:@([numStr intValue])];
            i += 1
        }
        return splitVal
    }
    
    //********************************************************************************
    /**
       Returns the string representation of the number *val*.  A leading zero is removed.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    private func getNumberString (_ val: Decimal) -> String {
        var stringVal = val.description //  .stringValue
        let locale = Locale.current
        let dp = locale.decimalSeparator!
        let zero = "0" + dp
        
        if stringVal.hasPrefix(zero) {
            stringVal = stringVal.replacingOccurrences(of: zero, with: dp)
        }
        if getNumberColumnCount() > 0 && stringVal.count > getNumberColumnCount() {
            stringVal = stringVal.substring(0, getNumberColumnCount()-1)
        }
        return stringVal
    }
    
    //********************************************************************************
    /**
       Splits a number *val* into character-sized pieces and returns an array of
       these strings.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    private func split(_ val: Decimal?) -> [String] {
        if let val = val, val >= 0 {
            let stringVal = getNumberString(val)
            return splitStringToArray(stringVal)
        }
        return []
    }
    
    //********************************************************************************
    /**
       Formats a number *val* into a fixed number of decimal places and
               leading digits which are split and returned as an array of strings.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    private func splitAndPad(val: Decimal) -> [String] {
        let splitVal = split(val)
        let countNumberCols = getNumberColumnCount()
        if splitVal.count < countNumberCols {
            var numFloatPrecision = 0
            var stringLength = countNumberCols
            if decimalColumn >= 0 {
                stringLength += 1
                numFloatPrecision = countNumberCols - decimalColumn
            }
            
            let formatted = String(format:"%0\(stringLength).\(numFloatPrecision)f", val.double)
            return splitStringToArray(formatted)
        }
        return splitVal
    }

    
    //********************************************************************************
    /**
       Clear strong pointers when this object is deallocated.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    deinit {
//        rate = nil
        valueChangeCallback = nil
        formatter = nil
        _columnValues = []
        negativeColumnValues = []
        labels = []
    }
    
    //********************************************************************************
    /**
       Convenience initializer for the *NumberPicker objects.  Esssentially
               the *maxValue* is analyzed and broken down into columns where each
               column contains the values from 0 to 9.  The *columnValues*
               property holds all the column arrays.  For example, if *maxValue*
               = 999.9; four columns are created.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    convenience init(maxValue: Decimal, andIncrement increment: Decimal) {
        self.init(maximum:maxValue, minimum:0, andIncrement:increment)
    }
    
    //********************************************************************************
    /**
       Produces a maximum number template for *number*.  For example, a
               number like 179.999 is converted into 199.999.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    private func generateRangeFromNumber (_ number: Decimal) -> Decimal {
        // convert numbers like 179.999 into 199.999
        var maxString = "\(number)"
        let start : Int = number.isSignMinus ? 2 : 1   // account for extra offset for negative numbers
        for i in start..<maxString.count {
            let ch = maxString[i]
            if ch != "." && ch != "9" {
                maxString[i] = "9"
            }
        }
        return Decimal(string: maxString)!
    }
    
    //********************************************************************************
    /**
       Produces a maximum number template for *number* with a certain *increment*.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    private func getRangeForNumber(number: Decimal, withIncrement increment: Decimal) -> Decimal {
        var number = number
        if !number.isSignMinus { number = number + increment }
        else { number = number - increment }
        return generateRangeFromNumber(number)
    }
    
    //********************************************************************************
    /**
       Produces an array of digits from *0* to *9* given a set of maximum
               *digits* with *maxColumns*.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    private func generateColumnsFromDigits(digits: [String], withMaxColumns maxColumns:Int) -> [[String]] {
        var columnValues : [[String]] = []
        var columnIndex = maxColumns
        for _ in 0..<maxColumns {
            var max = 9
            if columnIndex == digits.count {
                max = Int(digits[0])!
            } else if columnIndex > digits.count {
                max = 0
            }
            var column : [String] = []
            for j in 0...max {
                column.append("\(j)")
            }
            columnValues.append(column)
            columnIndex -= 1
        }
        return columnValues
    }

    //********************************************************************************
    /**
       Extended initializer that also handles negative numbers.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    init(maximum: Decimal, minimum: Decimal, andIncrement increment: Decimal) {
        super.init()
        kindOfPicker = .number
        decimalColumn = -1
        minValue = minimum
        maxValue = maximum
//        rate = nil
        let digits = split(getRangeForNumber(number: maxValue, withIncrement:increment))
        let minDigits = split(getRangeForNumber(number: abs(minimum), withIncrement:increment))
        var maxColumns = max(minDigits.count, digits.count)
        
        // define the positive column values
        let isNegative = minimum.isSignMinus
        if isNegative {
            maxColumns += 1         // need extra column for negative sign
            decimalColumn += 1      // also adjust the decimal position
        }
        _columnValues = generateColumnsFromDigits(digits: digits, withMaxColumns:maxColumns)
        
        // define the negative column values -- if any
        negativeColumnValues = []
        if isNegative {
            negativeColumnValues = generateColumnsFromDigits(digits: minDigits, withMaxColumns:maxColumns)
        }
        
    }
    
    //********************************************************************************
    /**
       Initializer for *NumberPicker* objects that also adds a rightmost
               column containing *labels*.  These *labels* can be anything like
               units, metric scalers, or any set of strings.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    convenience init(maximum maxValue: Decimal, andIncrement increment: Decimal, andLabels labels: [String]) {
        self.init(maxValue: maxValue, andIncrement:increment)
        self.labels = labels
        _columnValues.append(labels)
        negativeColumnValues = []
    }
    
    //********************************************************************************
    /**
       Initializer for *NumberPicker* objects that also adds a rightmost
               column containing *labels*.  These *labels* can be anything like
               units, metric scalers, or any set of strings.  This version also
               supports a minimum negative value.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    convenience init(maximum max: Decimal, minimum min: Decimal, andIncrement increment: Decimal, andLabels labels: [String]) {
        self.init(maximum:max, minimum:min, andIncrement:increment)
        self.labels = labels
        _columnValues.append(labels)
        if negativeColumnValues.count > 0 {
            negativeColumnValues.append(labels)
        }
    }
    
    //********************************************************************************
    /**
       Initializer for *NumberPicker* objects that uses a fixed number of
               stepper rows defined by the difference between the *maximum* and
               *minimum* values divided by the *step* size.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    init(withRangeOfNumbers minimum: Decimal, maximum: Decimal, stepSize step: Decimal, labels: [String]) {
        super.init()
        minValue = minimum
        maxValue = maximum
        stepSize = step
        
        // create the rows for this control
        var number = maximum
        var column : [String] = []
        while number > minimum {
            column.append(formatter!.string(from:number as NSDecimalNumber)!)
            number = number - step
        }
        _columnValues.append(column)
        _columnValues.append(labels)
        self.labels = labels
        value = minimum
        kindOfPicker = .minMax
//        rate = nil
    }

    
    //********************************************************************************
    /**
       Initializer for *NumberPicker* objects that use a rate.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
//    init(rate: Rate) {
//        self.rate = rate
//        kindOfPicker = .rate
//    }
    
    //********************************************************************************
    /**
       Returns the selected label in the *picker*.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    func getSelectedLabel(picker: PickerView) -> String {
        var labelVal = ""
        if labels.count > 0 && columnValues.count > 0 {
            let columns = picker.numberOfComponents
            let pickerSelection = picker.selectedRow(inComponent: columns-1)
            labelVal = labels[pickerSelection]
        }
        return labelVal
    }
    
    //********************************************************************************
    /**
       Sets the current *picker* column indices to match the number *val*.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    private func set(_ picker: PickerView, toCurrentValue val: Any) {
        if kindOfPicker == .minMax {
            let number = val as! Decimal
            value = number
            let index = (maxValue - number) / stepSize
            picker.selectRow(Int(index.double), inComponent: 0, animated: true)
//        } else if kindOfPicker == .rate && val is Rate {
//            rate = val as? Rate
//            picker.selectRow(rate!.timeIndex, inComponent:0, animated:true)  // set time
//            picker.selectRow(rate!.unitIndex, inComponent:1, animated:true)   // set units
        } else if kindOfPicker == .number && val is Decimal {
            var val = val as! Decimal
            if minValue > val { val = minValue }
            value = val
            if isNegativeNumber {
                // remove the negative sign for display purposes
                val = -val
            }
            let splitVal = splitAndPad(val: val)
            let diff = getNumberColumnCount() - splitVal.count
            let startRow = negativeColumnValues.count > 0 ? 1 : 0
            
            for i in startRow..<getNumberColumnCount() {
                if i < diff {
                    picker.selectRow(0, inComponent:i, animated:true)
                } else {
                    let row = Int(splitVal[i-diff-startRow])!
                    let comps = picker.numberOfComponents
                    if i < comps {
                        let rows = picker.numberOfRows(inComponent: i)
                        if row < rows { picker.selectRow(row, inComponent:i, animated:true) }
                    }
                }
            }
            
            if negativeColumnValues.count > 0 {
                picker.selectRow(isNegativeNumber ? 1 : 0, inComponent:0, animated:true)
            }
            
            if findMaximumRow(getPickerNumberAsString(picker: picker)) {
                picker.reloadAllComponents()
            }
        }
    }
    
    //********************************************************************************
    /**
       Determines the position marker *maxActiveRow* to delineate up to
               which column zeros should be replaced by blanks.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    private func findMaximumRow(_ number: String) -> Bool {
        // find leading non-zero digit in string to reset leading zeros
        let range = (number as NSString).rangeOfCharacter(from: CharacterSet(charactersIn: "123456789"))
        if range.location != NSNotFound {
            if range.location+1 != maxActiveRow {
                maxActiveRow = min(decimalColumn, range.location+1)
                if maxActiveRow == number.count { maxActiveRow -= 1 }
            }
        } else if decimalColumn < 0 {
            maxActiveRow = number.count-1
        } else {
            maxActiveRow = decimalColumn
        }
        return true
    }
    
    //********************************************************************************
    /**
       Sets both the current *picker* column indices to match the number
               *val* and sets the units column to match *label*.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    func set(_ picker: PickerView, toCurrentValue val: Any, label: String = "") {
        set(picker, toCurrentValue:val)
        if label == "" { return }
        for i in 0..<labels.count {
            let labelVal = labels[i]
            if labelVal == label {
                picker.selectRow(i, inComponent:picker.numberOfComponents - 1, animated:true)
            }
        }
    }
    
    // MARK: - Picker Delegate methods
    
    //********************************************************************************
    /**
       Picker delegate method to return the number of columns.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    func numberOfComponents(in pickerView: PickerView) -> Int {
        if kindOfPicker == .rate {
            return 2
        }
        if negativeColumnValues.count > 0 {
            return negativeColumnValues.count+1
        }
        return columnValues.count
    }
    
    //********************************************************************************
    /**
       Picker delegate method to return the number of rows in a *component* column.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    func pickerView(_ pickerView: PickerView, numberOfRowsInComponent component: Int) -> Int {
//        if kindOfPicker == .rate {
//            if component == 0 {
//                return rate!.maxIndexForTime
//            } else {
//                return rate!.maxIndexForUnits
//            }
//        }
        if negativeColumnValues.count > 0 {
            if component == 0 { return 2 }
            if isNegativeNumber {
                return negativeColumnValues[component-1].count
            } else {
                return columnValues[component-1].count
            }
        }
        return columnValues[component].count
    }
    
    //********************************************************************************
    /**
       Returns a string for the *component* column
               and the *row* in that column.  If a decimal point was present in the
               maximum number, the decimal point is displayed in the correct column.
               Any leading zeros are removed from their columns and replaced with a
               blank row (e.g., a number like 003.20 is displayed as 3.20).
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    private func stringFor(pickerView: PickerView, titleForRow row:Int, forComponent component:Int) -> String {
        var string : String
        var component = component
        if kindOfPicker == .minMax {
            let column = columnValues[component]
            string = column[row]
//        } else if kindOfPicker == .rate {
//            if component == 0 {
//                return rate!.stringForTimeIndex(row)
//            } else {
//                return rate!.stringForUnitIndex(row)
//            }
        } else {
            if negativeColumnValues.count > 0 {
                if component == 0 {
                    if row == 0 {
                        return " "
                    } else {
                        return "-"
                    }
                }
                component -= 1
            }
            
            let column = isNegativeNumber && negativeColumnValues.count > 0 ? negativeColumnValues[component] : columnValues[component]
            if decimalColumn == component+1 {
                let locale = Locale.current
                let dp = locale.decimalSeparator!
                string = column[row] + " " + dp
            } else {
                if row == 0 && maxActiveRow > component { string = " " }
                else { string = column[row] }
            }
        }
        return string
    }
    
    //********************************************************************************
    /**
       Font for picker columns.
     
       - Author:  Michael Griebling
       - Date:    10 September 2013
     
     ******************************************************************************** */
    private func fontForComponent(_ component: Int) -> Font {
        let isPad = Device.current.userInterfaceIdiom == .pad
        if kindOfPicker == .number && !isPad && component == getNumberColumnCount() {
            return Font.boldSystemFont(ofSize:12)
        } else {
            return Font.boldSystemFont(ofSize:18)
        }
    }
    
    //********************************************************************************
    /**
       Picker delegate method to return a view containing a centred string.
     
       - Author:  Michael Griebling
       - Date:    15 July 2013
     
     ******************************************************************************** */
    func pickerView(_ pickerView: PickerView, viewForRow row: Int, forComponent component: Int, reusing view: View?) -> View {
        var label : Label!
        var view = view
        if view == nil {
            label = Label(frame: Rect(x:0, y:0, width:250, height:50))
            view = label
        } else {
            label = view as! Label
        }
        label.textAlignment = .center
        label.textColor = Color.black
        label.backgroundColor = Color.clear
        label.font = fontForComponent(component)
        label.text = stringFor(pickerView: pickerView, titleForRow:row, forComponent:component)
        label.lineBreakMode = .byTruncatingTail
        return view!
    }
    
    //********************************************************************************
    /**
       Picker delegate method that is activated whenever the user selects
               a different *row* in a column *component*.  This method ensures
               that the internal *value* property tracks the user interface and
               keeps leading zeros from appearing.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    func pickerView(_ pickerView: PickerView, didSelectRow row: Int, inComponent component: Int) {
        // update the internal number representation
        if kindOfPicker == .minMax {
            let column = columnValues[0]
            let number = formatter!.number(from: column[row])
            value = number!.decimalValue
//        } else if kindOfPicker == .rate {
//            if component == 1 {
//                // update the units
//                rate!.setUnitFromUnitIndex(row)
//            } else {
//                // update the time
//                rate!.setTimeFromTimeIndex(row)
//            }
//            pickerView.reloadAllComponents()
//            if rate != nil {
//                pickerView.selectRow(rate!.timeIndex, inComponent:0, animated:true)  // set time
//                pickerView.selectRow(rate!.unitIndex, inComponent:1, animated:true)  // set units
//            }
//            valueChangeCallback?(self)
        } else {
            var stringValue = getPickerNumberAsString(picker: pickerView)
            var newValue = Decimal(string:stringValue)!
            if minValue > newValue {
                newValue = minValue
                stringValue = newValue.description
                set(pickerView, toCurrentValue:newValue)
            } else if maxValue < newValue {
                newValue = maxValue
                stringValue = newValue.description
                set(pickerView, toCurrentValue:newValue)
            }
            value = newValue
            if findMaximumRow(stringValue) {
                pickerView.reloadAllComponents()
            }
        }
    }
    
    //********************************************************************************
    /**
       Picker delegate method to determine the width of each column
               *component*.
     
       - Author:  Michael Griebling
       - Date:    17 April 2013
     
     ******************************************************************************** */
    func pickerView(_ pickerView: PickerView, widthForComponent component: Int) -> Float {
        let OVERHEAD = 25
        let font = fontForComponent(component)
        let width = pickerView.bounds.size.width - 30
        let overhead = Device.current.userInterfaceIdiom == .pad ? OVERHEAD : 2*OVERHEAD/3
        var string: NSAttributedString
        if kindOfPicker == .minMax {
            if component == 1 { return width * 0.3 }
            else { return width * 0.7 }
        } else if kindOfPicker == .rate {
            if component == 0 { return width * 0.3 }
            else { return width * 0.7 }
        } else {
            let columnWidth = width / Float(columnValues.count)
            if decimalColumn == component+1 {
                let locale = NSLocale.current
                let dp = locale.decimalSeparator!
                string = NSAttributedString(string: "9 " + dp, attributes: [NSAttributedStringKey.font : font])
            } else if labels.count > 0 && component+1 == columnValues.count {
                string = NSAttributedString(string: labels.last!, attributes: [NSAttributedStringKey.font : font])
                return string.size().width+Float(overhead)
            } else {
                string = NSAttributedString(string: "9", attributes: [NSAttributedStringKey.font : font])
            }
            return min(columnWidth, string.size().width+Float(overhead))
        }
    }
    
}
