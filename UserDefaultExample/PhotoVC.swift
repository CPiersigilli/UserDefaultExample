//
//  PhotoVC.swift
//  UserDefaultExample
//
//  Created by Marco Piersigilli on 05/03/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//

import UIKit

class PhotoVC: UIViewController {
    
//    var imageSelected = UIImage()
    var selectedCDMedia = CDMedia()


    @IBOutlet weak var scrollImage: ImageScrollView!
    //  @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var cancelMedia: UIBarButtonItem!
    @IBOutlet weak var saveMedia: UIBarButtonItem!
    
    
    @IBAction func savePhotoToServer(_ sender: UIBarButtonItem) {
        guard ifReachability() else {
            alertIfReachability(self)
            return
        }
        
        //  Verfica che le preferenze siano tutte presenti, ma non riesce a verificare che siano corrette.
        guard checkSettings(self) else {
            return
        }
        
        cancelMedia.isEnabled = false
        saveMedia.isEnabled = false
        WebdavUtility.shared.upLoadMedia(vc: self,view: view, media: selectedCDMedia)
    }
    
    @IBAction func cancelPhoto(_ sender: UIBarButtonItem) {
        cancelMedia.isEnabled = false
        saveMedia.isEnabled = false
        let nameMedia = selectedCDMedia.name!
        guard CDController.shared.deleteMedia(media: selectedCDMedia)  else {
            alertIfError(self, title: "ATTENZIONE", message: "Media non eliminato.")
            return
        }
        alertIfError(self, title: nameMedia, message: "Media eliminato con successo.")
//        image.image = UIImage(named: "noPhoto")
        // Torna al CollectionViewController
        navigationController?.popViewController(animated: true)
//        performSegue(withIdentifier: "unwindToCollectionVC", sender: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        image.image = UIImage(data: selectedCDMedia.mediaType! as Data)
        scrollImage.display(image: UIImage(data: selectedCDMedia.mediaType! as Data)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
