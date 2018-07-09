//
//  AlertUtility.swift
//  GeoPhoto
//
//  Created by Marco Piersigilli on 23/06/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//

import UIKit

// Determina il ViewController attivo per evitare di passarlo quale dato ai vari alertcontroller
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}



// MARK: Alert vari

//   Alert che avvisa dell'errore nel settaggio delle preferenze della app
func alertCheckPreferences (title:String, message:String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    alert.addAction(UIAlertAction(title: "Preferences...", style: .default, handler: {action in
        goToPreferencesSetting()
    }))
    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
    if let activeVC = UIApplication.topViewController() {
        activeVC.present(alert, animated: true)
    }
}

//   Funzione che consente di raggiungere le preferenze della app
//func goToPreferencesSetting() {
//    let application = UIApplication.shared
//    let url = URL(string: UIApplicationOpenSettingsURLString)! as URL
//    if application.canOpenURL(url) {
//        application.open(url, options:["":""] , completionHandler: nil)
//    }
//}

/*   Alert che avvisa di un errore
     Ad esempio per segnalare l'assenza di connessione:
     title:     "ATTENZIONE"
     message:   "No connessione internet"
*/
func alertIfError (title:String, message:String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    if let activeVC = UIApplication.topViewController() {
        activeVC.present(alert, animated: true)
    }
}

//   Alert che cancella il media selezionato o attivo
//func deleteMedia (media:CDMedia) {
//    var alert = UIAlertController()
//    if media.type == .movie {
//        alert = UIAlertController(title: "CANCELLA VIDEO", message: "Questo video sarà eliminata senza possibilità di ripristino.", preferredStyle: .actionSheet)
//    } else {
//        alert = UIAlertController(title: "CANCELLA FOTO", message: "Questa foto sarà eliminata senza possibilità di ripristino.", preferredStyle: .actionSheet)
//    }
//
//    if media.type == .movie {
//        alert.addAction(UIAlertAction(title: "Elimina video", style: .default, handler: {action in
//            deleteMedia(media: media)
//        }))
//    } else {
//        alert.addAction(UIAlertAction(title: "Elimina foto", style: .default, handler: {action in
//            deleteMedia(media: media)
//        }))
//    }
//
//    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//    if let activeVC = UIApplication.topViewController() {
//        activeVC.present(alert, animated: true)
//    }
//}


