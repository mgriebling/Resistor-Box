//
//  UserSettingsViewController.swift
//  Resistor Box
//
//  Created by Mike Griebling on 25 Mar 2018.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class UserSettingsViewController : UIViewController {
    
    @IBOutlet weak var resistorImage: UISegmentedControl!
    @IBOutlet weak var shadows: UISwitch!
    @IBOutlet weak var minResistance: UIButton!
    @IBOutlet weak var maxResistance: UIButton!
    @IBOutlet weak var background1: UIButton!
    @IBOutlet weak var background2: UIButton!
    @IBOutlet weak var background3: UIButton!
    
    @IBAction func returnToResistorView(_ segue: UIStoryboardSegue?) { /* stub to return from pop-ups */ }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set up the GUI elements
        self.navigationItem.title = "User Settings"
        shadows.setOn(preferences.useShadows, animated: false)
        resistorImage.selectedSegmentIndex = preferences.useEuroSymbols ? 1 : 0
        minResistance.setTitle(Resistors.stringFrom(preferences.minResistance), for: .normal)
        maxResistance.setTitle(Resistors.stringFrom(preferences.maxResistance), for: .normal)
        background1.setTitle(preferences.color1, for: .normal)
        background1.backgroundColor = ColorPicker.colors[preferences.color1]!
        background2.setTitle(preferences.color2, for: .normal)
        background2.backgroundColor = ColorPicker.colors[preferences.color2]!
        background3.setTitle(preferences.color3, for: .normal)
        background3.backgroundColor = ColorPicker.colors[preferences.color3]!
    }
    
    @IBAction func changedResistorImage(_ sender: UISegmentedControl) {
        preferences.useEuroSymbols = sender.selectedSegmentIndex > 0
        
        if let tbc = tabBarController, let items = tbc.tabBar.items {
            items.first!.image = UIImage(named: preferences.useEuroSymbols ? "EResistor" : "Resistor")
            items.first!.selectedImage = UIImage(named: preferences.useEuroSymbols ? "EResistor" : "Resistor")
            items[2].image = UIImage(named: preferences.useEuroSymbols ? "EDivider" : "Divider")
            items[2].selectedImage = UIImage(named: preferences.useEuroSymbols ? "EDivider" : "Divider")
        }
    }
    
    @IBAction func changedShadows(_ sender: UISwitch) {
        preferences.useShadows = sender.isOn
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destNav = segue.destination
        let popPC = destNav.popoverPresentationController
        let colorSize = CGSize(width: 250, height: 250)
        if let button = sender as? UIButton {
            popPC?.sourceView = button
            popPC?.sourceRect = button.bounds
        }
        popPC?.delegate = self
        switch segue.identifier! {
        case "SelectMinResistance":
            if let vc = destNav.childViewControllers.first as? ResistancePickerViewController {
                vc.value = minResistance.title(for: .normal)
                vc.callback = { [weak self] newValue in
                    self?.minResistance.setTitle(newValue, for: .normal)
                    preferences.minResistance = Resistors.parseString(newValue).0
                }
            }
        case "SelectMaxResistance":
            if let vc = destNav.childViewControllers.first as? ResistancePickerViewController {
                vc.value = maxResistance.title(for: .normal)
                vc.callback = { [weak self] newValue in
                    self?.maxResistance.setTitle(newValue, for: .normal)
                    preferences.maxResistance = Resistors.parseString(newValue).0
                }
            }
        case "ChooseColor1":
            if let vc = destNav as? ColorPickerViewController {
                vc.preferredContentSize = colorSize
                vc.colorPicker.selectedColor = preferences.color1
                vc.callback = { name, newValue in
                    preferences.color1 = name
                    self.background1.setTitle(name, for: .normal)
                    self.background1.backgroundColor = newValue
                }
            }
        case "ChooseColor2":
            if let vc = destNav as? ColorPickerViewController {
                vc.preferredContentSize = colorSize
                vc.colorPicker.selectedColor = preferences.color2
                vc.callback = { name, newValue in
                    preferences.color2 = name
                    self.background2.setTitle(name, for: .normal)
                    self.background2.backgroundColor = newValue
                }
            }
        case "ChooseColor3":
            if let vc = destNav as? ColorPickerViewController {
                vc.preferredContentSize = colorSize
                vc.colorPicker.selectedColor = preferences.color3
                vc.callback = { name, newValue in
                    preferences.color3 = name
                    self.background3.setTitle(name, for: .normal)
                    self.background3.backgroundColor = newValue
                }
            }
        default: break
        }
    }
    
}

extension UserSettingsViewController : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // allows popover to appear for iPhone-style devices
        return .none
    }
    
}
