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
    
    @IBAction func returnToResistorView(_ segue: UIStoryboardSegue?) { popover = nil /* stub to return from pop-ups */ }
    
    private func setButtonColor (_ color : String, button: UIButton) {
        let buttonSize = button.bounds.size
        UIGraphicsBeginImageContextWithOptions(buttonSize, false, 0)
        ResistorImage.drawGradientButton(frame: button.bounds, resizing: .stretch, selectedGradientColor: ColorPicker.colors[color]!, label: color)
        let imageOfGradientButton = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        button.setBackgroundImage(imageOfGradientButton, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set up the GUI elements
        self.navigationItem.title = "User Settings"
        shadows.setOn(preferences.useShadows, animated: false)
        resistorImage.selectedSegmentIndex = preferences.useEuroSymbols ? 1 : 0
        minResistance.setTitle(Resistors.stringFrom(preferences.minResistance), for: .normal)
        maxResistance.setTitle(Resistors.stringFrom(preferences.maxResistance), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateButtons()
    }
    
    func updateButtons() {
        setButtonColor(preferences.color1, button: background1)
        setButtonColor(preferences.color2, button: background2)
        setButtonColor(preferences.color3, button: background3)
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
    
    weak var popover : UIPopoverPresentationController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destNav = segue.destination
        let popPC = destNav.popoverPresentationController
        let colorSize = CGSize(width: 250, height: 250)
        popover = popPC
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
                vc.callback = { [weak self] name, newValue in
                    guard let wself = self else { return }
                    preferences.color1 = name
                    wself.setButtonColor(name, button: wself.background1)
                }
            }
        case "ChooseColor2":
            if let vc = destNav as? ColorPickerViewController {
                vc.preferredContentSize = colorSize
                vc.colorPicker.selectedColor = preferences.color2
                vc.callback = { [weak self] name, newValue in
                    guard let wself = self else { return }
                    preferences.color2 = name
                    wself.setButtonColor(name, button: wself.background2)
                }
            }
        case "ChooseColor3":
            if let vc = destNav as? ColorPickerViewController {
                vc.preferredContentSize = colorSize
                vc.colorPicker.selectedColor = preferences.color3
                vc.callback = { [weak self] name, newValue in
                    guard let wself = self else { return }
                    preferences.color3 = name
                    wself.setButtonColor(name, button: wself.background3)
                }
            }
        default: break
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            if let pover = self.popover {
                if let button = pover.sourceView as? UIButton {
                    button.setNeedsLayout()
                    button.layoutIfNeeded()
                }
            }
        }, completion: nil)
    }
    
}

extension UserSettingsViewController : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // allows popover to appear for iPhone-style devices
        return .none
    }
    
}
