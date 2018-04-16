//
//  ColorPickerViewController.swift
//  Resistor Box Mac
//
//  Created by Michael Griebling on 2018-04-16.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import Cocoa

public typealias Color = NSColor   // needed for generic user preferences

class ColorPickerViewController: NSViewController {

    @IBOutlet weak var colorCollection: NSCollectionView! {
        didSet {
            colorCollection.dataSource = self
            colorCollection.delegate = self
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        colorCollection.reloadData()
    }
    
}

extension ColorPickerViewController : NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return Store.colors.count
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ColorViewItem"), for: indexPath)
        guard let collectionViewItem = item as? ColorViewItem else { return item }
        
        collectionViewItem.colorID =  Store.colors.keys.sorted()[indexPath.item]
        return collectionViewItem
    }
    
}

extension ColorPickerViewController : NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        print("Selected \(indexPaths)")
    }
    
}
