//
//  MenuViewController.swift
//  Resistor Box
//
//  Created by Mike Griebling on 2 Apr 2018.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var minResistance: UIBarButtonItem!
    @IBOutlet weak var collectionButton: UIBarButtonItem!
    
    var base : BaseViewController?
    
    @IBAction func returnToResistorView(_ segue: UIStoryboardSegue?) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        minResistance.title = base?.minResistance.title
        collectionButton.title = base?.collectionButton.title
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        base?.minResistance.title = minResistance.title
        base?.collectionButton.title = collectionButton.title
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destNav = segue.destination
        let popPC = destNav.popoverPresentationController
        base?.popover = popPC
        popPC?.delegate = self
        switch segue.identifier {
        case "EditResistance":
            if let vc = destNav.childViewControllers.first as? ResistancePickerViewController {
                let r = minResistance.title!.dropFirst()  // remove ">"
                vc.value = String(r)
                vc.callback = { [weak self] newValue in
                    self?.base?.minR = Resistors.parseString(newValue)
                    self?.minResistance.title = ">" + newValue
                    self?.base?.calculateOptimalValues()
                }
            }
        case "SelectCollection":
            if let vc = destNav.childViewControllers.first as? CollectionViewController {
                vc.value = collectionButton.title
                vc.callback = { [weak self] newValue in
                    self?.collectionButton.title = newValue
                    Resistors.active = newValue
                    self?.base?.calculateOptimalValues()
                }
            }
        default: break
        }
    }

}

extension MenuViewController : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // allows popover to appear for iPhone-style devices
        return .none
    }
    
}
