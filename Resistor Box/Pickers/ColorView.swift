//
//  ColorView.swift
//  Resistor Box
//
//  Created by Mike Griebling on 25 Mar 2018.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class ColorView: UIView {
    
    var color = UIColor.lightGray
    var label = "Light Gray"
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        ResistorImage.drawGradientView(frame: rect, resizing: .aspectFill, selectedGradientColor: color, label: label)
    }

}
