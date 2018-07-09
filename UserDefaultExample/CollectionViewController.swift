//
//  CollectionViewController.swift
//  UserDefaultExample
//
//  Created by Marco Piersigilli on 04/03/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "collectionViewCell"
private let sectionReuseIdentifier = "headerSection"

class CollectionViewController: UICollectionViewController {
    var fetchedController: NSFetchedResultsController<CDMedia>!
    var selectedMedia = CDMedia()
    
    @IBOutlet var myCollectionView: UICollectionView!
    @IBOutlet weak var multipleSelection: UIBarButtonItem!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    @IBOutlet weak var saveMediaBtn: UIBarButtonItem!
    @IBOutlet weak var cancelMediaBtn: UIBarButtonItem!
        
    @IBAction func multipleSelectionBtn(_ sender: UIBarButtonItem) {
        print("multipleSelection Button")
        if multipleSelection.title == "Seleziona" {
//            navigationController?.navigationBar.backItem?.hidesBackButton = true
            // Mostra la toolBar
            navigationController?.isToolbarHidden = false
            saveMediaBtn.isEnabled = false
            cancelMediaBtn.isEnabled = false
            
            navigationTitle.hidesBackButton = true
            multipleSelection.title = "Annulla"
            navigationTitle.title = "Seleziona"
            myCollectionView.allowsMultipleSelection = true
        } else {
//            navigationController?.navigationBar.backItem?.hidesBackButton = true
            // Nasconde la toolBar
            navigationController?.isToolbarHidden = true
            // Mostra il Back button
            navigationTitle.hidesBackButton = false
            // Mostra "Selezione" al bottone
            multipleSelection.title = "Seleziona"
            navigationTitle.title = "Media"
            if let selectedItems = collectionView?.indexPathsForSelectedItems {
                for i in 0..<selectedItems.count {
                    let cell = collectionView?.cellForItem(at: selectedItems[i]) as! CollectionViewCell
                    cell.checkmarkView.isHidden = true
                }
            }
            myCollectionView.allowsMultipleSelection = false
        }
    }
    
//    @IBAction func backToMain(_ sender: UIBarButtonItem) {
//        navigationController?.popViewController(animated: true)
//    }
    
    @IBAction func saveSelectedMedia(_ sender: UIBarButtonItem) {
//        if let selectedItems = collectionView?.indexPathsForSelectedItems {
        if let selectedItems = myCollectionView.indexPathsForSelectedItems {
            print("Hai selezionato: \(selectedItems.count)")
            print("Elenco media selezionati")
            for i in 0..<selectedItems.count {
                print("Item: \(selectedItems[i])")
            }
        }
    }
    
    fileprivate func extractedcancelSelectedMedia() {
        self.fetchedController = CDController.shared.groupMediaForDay()
        self.myCollectionView.reloadData()
        
        self.saveMediaBtn.isEnabled = false
        self.cancelMediaBtn.isEnabled = false
    }
    
    @IBAction func cancelSelectedMedia(_ sender: UIBarButtonItem) {
        var numSelectedMedia:Int!
        if let selectedItems = myCollectionView.indexPathsForSelectedItems {
            numSelectedMedia = selectedItems.count
            if numSelectedMedia > 0 {
                if numSelectedMedia == 1 {
                    let alert = UIAlertController(title: "ATTENZIONE!!!",
                                                  message: "Sei sicuro di voler eliminare il media selezionato definitivamente?",
                                                  preferredStyle: UIAlertControllerStyle.actionSheet)
                    alert.addAction(UIAlertAction(title: "Elimina il media selezionato", style: .destructive, handler: { (action: UIAlertAction!) in
                        self.selectedMedia = self.fetchedController.object(at: selectedItems[0])
                        guard CDController.shared.deleteMedia(media: self.selectedMedia) else {
                            print("Il media non è stato eliminato.")
                            return
                        }
                        self.extractedcancelSelectedMedia()
                    }))
                    alert.addAction(UIAlertAction(title: "Annulla", style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "ATTENZIONE!!!",
                                                  message: "Sei sicuro di voler eliminare i \(numSelectedMedia!) media selezionati definitivamente?",
                                                  preferredStyle: UIAlertControllerStyle.actionSheet)
                    alert.addAction(UIAlertAction(title: "Elimina i \(numSelectedMedia!) media selezionati", style: .destructive, handler: { (action: UIAlertAction!) in
                        for i in 0..<numSelectedMedia! {
                            self.selectedMedia = self.fetchedController.object(at: selectedItems[i])
                            guard CDController.shared.deleteMedia(media: self.selectedMedia) else {
                                print("Il media non è stato eliminato.")
                                return
                            }
                        }
                        self.extractedcancelSelectedMedia()
                    }))
                    alert.addAction(UIAlertAction(title: "Annulla", style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Nasconde la toolBar
        navigationController?.isToolbarHidden = true
        
        fetchedController = CDController.shared.groupMediaForDay()
        myCollectionView.reloadData()
        print("CollectionViewController - viewWillAppear - \(myCollectionView.numberOfItems(inSection: 0))")
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    // Determina il numero delle sezioni
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("override func numberOfSections(in collectionView: UICollectionView) -> Int {")
        // #warning Incomplete implementation, return the number of sections
        if let sections = fetchedController.sections {
            return sections.count
        }
        return 1
    }

    // Determina il numero degli item per ciascuna sezione
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {")
        // #warning Incomplete implementation, return the number of items
        print("collectionView - \(CDController.shared.numberOfMedia())")
        if let sections = fetchedController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    // Assegna il testo all'header della CollectionView
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print("override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {")
        let sections = fetchedController.sections
        let sectionInfo = sections![indexPath.section]
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: sectionReuseIdentifier, for: indexPath) as! CollectionReusableView
            headerView.sectionLabel.text = sectionInfo.name
            return headerView
        default:
            assert(false, "Error")
        }
    }

    // Determina il numero degli item per ciascuna sezione
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        updateCell(cell: cell, path: indexPath)
        return cell
    }

    // Assegna l'immagine all'item della CollectionView
    func updateCell(cell: CollectionViewCell, path: IndexPath) {
        print("func updateCell(cell: CollectionViewCell, path: IndexPath)")
        let media = fetchedController.object(at: path)
        if let image = UIImage(data: media.mediaType! as Data) {
            cell.imageView.image = image
            cell.videoIndicator.isHidden = true
            cell.checkmarkView.isHidden = true
        }
//        cell.imageView.image = UIImage(data: media.mediaType! as Data)
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        print("override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {")
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            if selectedItems.count >= 0 {
                saveMediaBtn.isEnabled = true
                cancelMediaBtn.isEnabled = true
            }
        }
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        print("override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {")
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            if selectedItems.count <= 1 {
                saveMediaBtn.isEnabled = false
                cancelMediaBtn.isEnabled = false
            }
        }
        return true
    }
    
    // MARK: - Navigation
    //  Determina la foto che si sta deselezionando
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)")
        selectedMedia = fetchedController.object(at: indexPath)
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        cell.checkmarkView.isHidden = true
    }
    
    //  Determina la foto che si sta selezionando
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {")
        selectedMedia = fetchedController.object(at: indexPath)
//        if selectedMedia == .movie {
//            self.performSegue(withIdentifier: "segueToPlayVideoVC", sender: self)
//        } else {
//            self.performSegue(withIdentifier: "segueToShowPhotoVC", sender: self)
//        }
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        if !myCollectionView.allowsMultipleSelection {
            cell.checkmarkView.isHidden = true
            performSegue(withIdentifier: "segueToShowPhotoVC", sender: self)
        } else {
            cell.checkmarkView.isHidden = false
        }
    }
    
    //  Invia i dati al vc selezionato in base di tipo di media: foto o video
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("override func prepare(for segue: UIStoryboardSegue, sender: Any?) {")
        guard let identifier = segue.identifier else {
            print("il segue non ha un identifier, esco dal prepareForSegue")
            return
        }
        // Controllo l'identifier perché potrebbero esserci più di un Segue che parte da questo VC
        switch identifier {
        case "segueToShowPhotoVC":
            let vc_destinazione = segue.destination as! PhotoVC
            vc_destinazione.selectedCDMedia = selectedMedia
        default:
            print("Nessun segue conosciuto")
            return
        }
    }
}
