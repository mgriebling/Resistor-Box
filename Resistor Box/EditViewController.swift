//
//  EditViewController.swift
//  Resistor Box
//
//  Created by Mike Griebling on 10 Mar 2018.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {

    @IBOutlet weak var resistorSets: UITableView! {
        didSet { resistorSets.dataSource = self; resistorSets.delegate = self }
    }
    
    @IBOutlet weak var resistors: UICollectionView! {
        didSet { resistors.dataSource = self; resistors.delegate = self }
    }
    
    @IBOutlet weak var resistorsTitle: UIButton! {
        didSet { resistorsTitle.setTitle(Resistors.active + " Resistors", for: .normal) }
    }
    
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var selectedResistors = Set<IndexPath>()
    
    @IBAction func returnToResistorView(_ segue: UIStoryboardSegue?) {
        // return to here from exit segue
        resistorSets.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // highlight the active resistor set
        selectActiveResistorSet()
        
        // delete is inactive
        deleteBarButton.isEnabled = selectedResistors.count > 0
        
        // check if sharing is allowed
        shareButton.isEnabled = true
    }
    
    @IBAction func shareCollection(_ sender: UIBarButtonItem) {
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // save any changes made during editing
        Resistors.writeInventory()
    }
    
    @IBAction func deleteResistors(_ sender: Any) {
        var resistorArray = [IndexPath]()
        resistorArray.append(contentsOf: selectedResistors)
        
        // remove the selected resistors from the data structure
        for r in selectedResistors {
            // Note: offset by one because we don't show SHORTs
            Resistors.rInv[Resistors.active]?.remove(at: r.row+1)
        }

        // remove the selected resistors from the collection
        resistors.deleteItems(at: resistorArray)
        resistorSets.reloadData()           // refresh resistor quantities
        deleteBarButton.isEnabled = false
    }
    
    func selectActiveResistorSet() {
        // highlight the active resistor set
        let keys = Resistors.sortedKeys()
        if let index = keys.index(of: Resistors.active) {
            let pos = IndexPath(row: index, section: 0)
            resistorSets.selectRow(at: pos, animated: false, scrollPosition: .none)
            resistorsTitle.setTitle(Resistors.active + " Resistors", for: .normal)
            resistors.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PresentPicker" {
            let destNav = segue.destination
            if let vc = destNav.childViewControllers.first as? ResistancePickerViewController {
                vc.callback = { newValue in
                    let newR = Resistors.parseString(newValue)
                    if let _ = Resistors.rInv[Resistors.active]?.index(of: newR.0) { return } // ensure active collection is valid & no duplicates
                    
                    // find the insertion point for the new resistor (sorted by value)
                    for (index, r) in Resistors.rInv[Resistors.active]!.enumerated() {
                        if newR.0 < r {
                            Resistors.rInv[Resistors.active]!.insert(newR.0, at: index)
                            let path = [IndexPath(item: index, section: 0)]
                            self.resistors.performBatchUpdates({
                                self.resistors.insertItems(at: path)
                            }, completion: { done in
                                self.resistors.reloadData()
                            })
                            break
                        }
                    }
                }
            }
            let popPC = destNav.popoverPresentationController
            popPC?.delegate = self
        } else if segue.identifier == "AddCollection" {
            let destNav = segue.destination
            let popPC = destNav.popoverPresentationController
            popPC?.delegate = self
        }
    }
    
}

extension EditViewController : UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // allows popover to appear for iPhone-style devices
        return .none
    }
    
}

extension EditViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Resistors.rInv.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        let keys = Resistors.sortedKeys()
        let key = keys[keys.index(keys.startIndex, offsetBy: indexPath.row)]
        cell.textLabel?.text = key + " Resistors (\(Resistors.rInv[key]!.count-2))"
        return cell
    }
 
}

extension EditViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keys = Resistors.sortedKeys()
        let key = keys[keys.index(keys.startIndex, offsetBy: indexPath.row)]
        Resistors.active = key
        selectActiveResistorSet()
        resistors.reloadData()   // update collection with the new resistors
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        DispatchQueue.main.async { [weak self] in
            self?.selectActiveResistorSet()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let keys = Resistors.sortedKeys()
            let key = keys[keys.index(keys.startIndex, offsetBy: indexPath.row)]
            Resistors.rInv.removeValue(forKey: key)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
            tableView.endUpdates()

            // select a new active resistor set
            Resistors.active = Resistors.rInv.first?.key ?? ""
            resistors.reloadData()   // update collection with the new resistors
        }
    }
    
}

extension EditViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = Resistors.rInv[Resistors.active]?.count {
            return count-2
        }
        return  0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath)
        if let myCell = cell as? ResistorCollectionViewCell {
            let resistor = Resistors.rInv[Resistors.active]?[indexPath.item+1] ?? 0
            let label = Resistors.stringFrom(resistor)
            myCell.resistor.image = ResistorImage.imageOfResistor(value: label)
            let selected = selectedResistors.contains(indexPath)
            myCell.backgroundColor = selected ? UIColor(white: 0.85, alpha: 1) : UIColor.white
        }
        return cell
    }
 
}

extension EditViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedResistors.contains(indexPath) {
            selectedResistors.remove(indexPath)
        } else {
            selectedResistors.insert(indexPath)
        }
        collectionView.reloadItems(at: [indexPath])
        deleteBarButton.isEnabled = selectedResistors.count > 0
    }
    
}


