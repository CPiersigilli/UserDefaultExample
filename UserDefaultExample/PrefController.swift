//
//  PrefController.swift
//  UserDefaultExample
//
//  Created by Marco Piersigilli on 06/02/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//

//import Foundation
import UIKit

// MARK: Funzione che determina il numero della Build e della Versione della App

// Legge la versione e la build della app
func setVersionAndBuildNumber() {
    let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    UserDefaults.standard.set(version, forKey: "version_preference")
    let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    UserDefaults.standard.set(build, forKey: "build_preference")
}

// MARK: Funzioni che verificano la correttezza degli inserimenti delle preferenza della App

// Legge le preferenze della app
// Funzione che può essere utilizzata dopo aver vericato che le preferenze siano tutte correttamente settate con la func checkSettings()
func readPreferences () -> (webdavURL:String, username:String, password:String, cartellaDefault:String, cartellaDefaultNoLoc:String) {
    let defaults = UserDefaults.standard
    //    let webdavURL = defaults.string(forKey: NSLocalizedString("webdavURL", comment: ""))
    let webdavURL = defaults.string(forKey: "webdavURL")
    let user = defaults.string(forKey: "username")
    let password = defaults.string(forKey: "password")
    let cartellaDefault = defaults.string(forKey: "cartellaDefault")
    let cartellaDefaultNoLoc = defaults.string(forKey: "cartellaDefaultNoLoc")
    return (webdavURL!, user!, password!, cartellaDefault!, cartellaDefaultNoLoc!)
}

// Funzione che verifica che le preferenze siano tutte correttamente settate
func checkSettings (_ viewController:UIViewController) -> Bool {
    let defaults = UserDefaults.standard
    
    let pathURL = defaults.string(forKey: "webdavURL")
    print("pathURL: \(pathURL)")
    guard pathURL != nil else {
        alertCheckPreferences(viewController, title: "ATTENZIONE", message: "Riempi WebDavURL textfield, altrimenti le foto/video saranno salvate soltanto nell'iphone.")
        return false
    }
    
    if URL(string: pathURL!) == nil {
        alertCheckPreferences(viewController, title: "ATTENZIONE", message: "Correggi \(pathURL!), altrimenti le foto/video saranno salvate soltanto nell'iphone.")
        return false
    }
    
    let user = defaults.string(forKey: "username")
    guard user != nil else {
        alertCheckPreferences(viewController, title: "ATTENZIONE", message: "Riempi Username textfield, altrimenti le foto/video saranno salvate soltanto nell'iphone.")
        return false
    }
    
    let password = defaults.string(forKey: "password")
    guard password != nil else {
        alertCheckPreferences(viewController, title: "ATTENZIONE", message: "Riempi Password textfield, altrimenti le foto/video saranno salvate soltanto nell'iphone.")
        return false
    }
    
    let cartellaDefault = defaults.string(forKey: "cartellaDefault")
    guard cartellaDefault != nil else {
        alertCheckPreferences(viewController, title: "ATTENZIONE", message: "Riempi Cartella Default textfield, altrimenti le foto/video saranno salvate soltanto nell'iphone.")
        return false
    }
    
    let cartellaDefaultNoLoc = defaults.string(forKey: "cartellaDefaultNoLoc")
    guard cartellaDefaultNoLoc != nil && cartellaDefaultNoLoc != "" else {
        defaults.set("MediaDaSistemare", forKey: "cartellaDefaultNoLoc")
        alertCheckPreferences(viewController, title: "ATTENZIONE", message: "Riempi Cartella Default No Loc textfield, altrimenti le foto e/o i video non geolocalizzati saranno salvati nella cartella \(folderNoLoc).")
        defaults.set(folderNoLoc, forKey: "cartellaDefaultNoLoc")
        return false
    }
    
    //    let user = "info@studiopiersigilli.it"
    //    let password = "gY5-2Ue-2E7-ABx"
    //    let pathURL = "https://webdav.pcloud.com"
    //    let cartellaDefault = "/Lavori/"
    
    return true
}

//   Funzione che consente di raggiungere le preferenze della app
func goToPreferencesSetting() {
    let application = UIApplication.shared
    let url = URL(string: UIApplicationOpenSettingsURLString)! as URL
    if application.canOpenURL(url) {
        application.open(url, options:["":""] , completionHandler: nil)
    }
}

// MARK: Alert vari

//   Alert che avvisa dell'errore nel settaggio delle preferenze della app
func alertCheckPreferences (_ viewController:UIViewController, title:String, message:String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    alert.addAction(UIAlertAction(title: "Preferences...", style: .default, handler: {action in
        goToPreferencesSetting()
    }))
    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
    
    viewController.present(alert, animated: true)
}

//   Alert che avvisa di un errore
func alertIfError (_ viewController:UIViewController, title:String, message:String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    viewController.present(alert, animated: true)
}

//   Alert che avvisa dell'assenza di connessione
func alertIfReachability (_ viewController:UIViewController) {
    let alert = UIAlertController(title: "Attenzione", message: "No connessione internet", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    viewController.present(alert, animated: true)
}

//   Funzione che rimuove l'alert che informa della progressione del Media sul WEBDAV Server
func alertDismissProgressbar (_ viewController:UIViewController) {
    viewController.dismiss(animated: true, completion: nil)
//    alert.dismiss(animated: true, completion: nil)
}

//   Funzione che mostra l'alert che informa della progressione del Media sul WEBDAV Server
func alertPresentProgressBar (_ viewController:UIViewController, alert:UIAlertController, progressBar: UIProgressView, title: String, message: String, progress: Float) {
    alert.title = title
    alert.message = message
    
    progressBar.progressViewStyle = .default
    progressBar.setProgress(0.0, animated: true)
    progressBar.frame = CGRect(x: 10, y: 65, width: 250, height: 0)
    alert.view.addSubview(progressBar)
    viewController.present(alert, animated: true, completion: nil)
}

//   Funzione che rimuove l'alert che informa della progressione del Media sul WEBDAV Server
func alertDismissIndicatorView (_ viewController:UIViewController) {
    viewController.dismiss(animated: true, completion: nil)
    //    alert.dismiss(animated: true, completion: nil)
}

//   Funzione che mostra l'alert che informa della progressione del Media sul WEBDAV Server
func alertPresentDownloadIndicatorView (_ viewController:UIViewController) {
    let alert = UIAlertController(title: "Update GeoFolder", message: "Attendere il download.", preferredStyle: .alert)
    let downloadIndicator = UIActivityIndicatorView(frame: CGRect(x: 150, y: 50, width: 22, height: 22))
//    downloadIndicator.center = viewController.view.center
    downloadIndicator.activityIndicatorViewStyle = .gray
    alert.view.addSubview(downloadIndicator)
    downloadIndicator.startAnimating()
    viewController.present(alert, animated: true, completion: nil)
}
