//
//  ColorViewItem.swift
//  Resistor Box Mac
//
//  Created by Michael Griebling on 2018-04-16.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import Cocoa

class ColorViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var colorSwatch: NSImageView!
    
    public var colorID : String = "Snow" {
        didSet {
            let color = Store.colors[colorID]!
            colorSwatch?.image = ResistorImage.imageOfGradientView(selectedGradientColor: color, label: colorID)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
