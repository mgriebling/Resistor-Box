//
//  TabViewController.swift
//  Resistor Box
//
//  Created by Mike Griebling on 29 Mar 2018.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class TabViewController: ContainerViewController {

    // just a placeholder for enabling the slide-in user preferences
    var slideDelegate : CenterViewControllerDelegate?
    
    

}

// MARK: - SidePanelViewControllerDelegate
extension CenterViewController: SidePanelViewControllerDelegate {

    func didFinish() {
        slideDelegate?.collapseSidePanels?()
    }
}

