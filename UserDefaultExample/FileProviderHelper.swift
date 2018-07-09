//
//  FileProviderHelper.swift
//  UserDefaultExample
//
//  Created by Marco Piersigilli on 03/03/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//

import Foundation
import UIKit

final class WebdavUtility {
    
    static let shared = WebdavUtility()
    private init() { }
    
    var webdavFile: WebDAVFileProvider?
    var hud: MBProgressHUD?
    var viewController: UIViewController?

    func upLoadMedia(vc:UIViewController, view:UIView, media:CDMedia) {
        //  Estrae i valori delle preferenze e definisce i parametri necessari.
        let pref = readPreferences()
        let myWebdavURL = URL(string: pref.webdavURL)
        viewController = vc //Assegna a viewController vc che è il ViewConroller da dove la funzione è stata chiamata
        let credential = URLCredential(user: pref.username, password: pref.password, persistence: .forSession)
//        hud = showIndicatorAnular(view: view, label: "Upload media", detailLabel: media.pathURL!)
        hud = showIndicatorAnularVC(viewController: vc, label: "Upload media", detailLabel: media.pathURL!)
        webdavFile = WebDAVFileProvider(baseURL: myWebdavURL!, credential: credential)
        webdavFile?.delegate = self
        // Crea la cartella dove salvare i media (foto e video) - se la cartella esiste da errore ma la funzione prosegue.
        _ = self.webdavFile?.create(folder: pref.cartellaDefaultNoLoc, at: pref.cartellaDefault, completionHandler: { (error) in
            if let error = error as? URLError {
                print("URLError.code.rawValue: \(error.code.rawValue)")
//                if error.code == .secureConnectionFailed {
                if error.code.rawValue == -1200 || error.code.rawValue == -1003 {
//                    DispatchQueue.main.async {
//                        showFailed(vc: vc, hud: self.hud!, label: String(describing: error.code), detailLabel: "L'URL è errato. Modificare.")
//                        alertCheckPreferences(vc, title: "ERRORE", message: "L'URL: \(pref.webdavURL) che hai inserito è errato. Devi modificarlo.")
//                    }
                    return
                }
            }
            if let error = error as? FileProviderHTTPError {
                print("error.code: \(error.code)")
                switch error.code {
                case .unauthorized:
                    print("unauthorized")
                    DispatchQueue.main.async {
//                    self.hud?.isUserInteractionEnabled = false
                        showFailed(vc: vc, hud: self.hud!, label: String(describing: error.code), detailLabel: "User e password errate.")
                        alertCheckPreferences(vc, title: "ERRORE", message: "User e/o password errate. Modificare.")
                    }
                    return
                case .notFound:
                    print("Webdav URL errato")
                    DispatchQueue.main.async {
//                        self.hud?.isUserInteractionEnabled = false
                        showFailed(vc: vc, hud: self.hud!, label: String(describing: error.code), detailLabel: "Webdav URL errato.")
                    }
                    return
                default:
                    print("Errore webdavFile: \(String(describing: error.errorDescription))")
                    break
                }
            }
            //Salva il media (foto o video) nel Webdav Server
            _ = self.webdavFile?.writeContents(path: media.pathURL!, contents: media.mediaType! as Data, atomically: true, overwrite: true) { (error) in
//                guard error == nil else {
//                    print("Error: \(error.debugDescription)")
//                    return
//                }
                if let error = error as? FileProviderHTTPError {
                    print("error.code: \(error.code)")
                    switch error.code {
                    case .unauthorized:
                        print("unauthorized")
                        DispatchQueue.main.async {
                        self.hud?.isUserInteractionEnabled = false
                        showFailed(vc: vc, hud: self.hud!, label: String(describing: error.code), detailLabel: "User e password errate.")
                        }
                        return
                    case .notFound:
                        print("Webdav URL errato")
                        DispatchQueue.main.async {
                        showFailed(vc: vc, hud: self.hud!, label: String(describing: error.code), detailLabel: "Webdav URL errato.")
                        }
                        return
                    default:
                        print("Errore webdavFile: \(String(describing: error.errorDescription))")
                        break
                    }
                }
                print("Media salvato nel webdavServer coorrettamente.")
                DispatchQueue.main.async {
                    print("Sono nell'ultima parte.")
                    self.hud?.isUserInteractionEnabled = false
                    print("media.pathURL = \(media.pathURL!)")
                    showSucceeded(vc: vc, hud: self.hud!, label: "Upload completato", detailLabel: media.pathURL!)
                    if CDController.shared.deleteMedia(media: media) {
                        print("Numero di media contenuti nel Coredata: \(CDController.shared.numberOfMedia()).")
                    }
                }
            }
        })
    }
}

// MARK: FileProviderDelegate

extension WebdavUtility:FileProviderDelegate {
    func fileproviderSucceed(_ fileProvider: FileProviderOperations, operation: FileOperationType) {
//        switch operation {
//        case .copy(let source, let destination):
//            print("Copy fileproviderSucceed - source: \(source) - destination: \(destination)")
//        case .create(let path):
//            print("Create fileproviderSucceed - filePath: \(path)")
//        case .modify(let path):
//            print("Modify fileproviderSucceed - filePath: \(path)")
////            DispatchQueue.main.async {
////                alertDismissProgressbar(self)
////            }
//        default:
//            break
//        }
    }
    
    func fileproviderFailed(_ fileProvider: FileProviderOperations, operation: FileOperationType, error: Error) {
        switch operation {
        case .copy(let source, let destination):
            print("Copy fileproviderFailed - source: \(source) - destination: \(destination) - error: \(error.localizedDescription)")
        case .create(let path):
            if let error = error as? URLError {
                //                if error.code == .secureConnectionFailed {
                if error.code.rawValue == -1200 || error.code.rawValue == -1003 {
                    //                    DispatchQueue.main.async {
                    showFailed(vc: self.viewController!, hud: self.hud!, label: String(describing: error.code), detailLabel: "L'URL è errato. Modificare.")
                    //                        alertCheckPreferences(viewController, title: "ERRORE", message: "L'URL: \(pref.webdavURL) che hai inserito è errato. Devi modificarlo.")
                    alertCheckPreferences(viewController!, title: "ERRORE", message: "L'URL: ?? che hai inserito è errato. Devi modificarlo.")
                    //                    }
                    return
                }
            }
            print("Failed Create fileproviderFailed - filePath: \(path) - error: \(error.localizedDescription)")
            if let error = error as? FileProviderWebDavError {
                switch error.code {
                case .unauthorized:
                    print("Non autorizzato. Modificare le credenziali.")
//                    return
                case .notFound:
                    print("Server non trovato.")
                default:
                    print("Errore webdavFile: \(String(describing: error.errorDescription))")
                    break
                }
            }
        case .modify(let path):
            print("Failed Modify fileproviderFailed - filePath: \(path) - error: \(error.localizedDescription)")
            if let error = error as? URLError {
                //                if error.code == .secureConnectionFailed {
                if error.code.rawValue == -1200 || error.code.rawValue == -1003 {
//                    DispatchQueue.main.async {
                        showFailed(vc: self.viewController!, hud: self.hud!, label: String(describing: error.code), detailLabel: "L'URL è errato. Modificare.")
//                        alertCheckPreferences(viewController, title: "ERRORE", message: "L'URL: \(pref.webdavURL) che hai inserito è errato. Devi modificarlo.")
                    alertCheckPreferences(viewController!, title: "ERRORE", message: "L'URL: ?? che hai inserito è errato. Devi modificarlo.")
//                    }
                    return
                }
            }
            if let error = error as? FileProviderWebDavError {
                switch error.code {
                case .unauthorized:
                    print("Non autorizzato. User e password errato.")
//                    return
                case .notFound:
                    print("Server non trovato. URL webdav server errato.")
//                    return
                default:
                    print("Errore webdavFile: \(String(describing: error.errorDescription))")
                    break
                }
            }
        default:
            break
        }
    }
    
    func fileproviderProgress(_ fileProvider: FileProviderOperations, operation: FileOperationType, progress: Float) {
        switch operation {
        case .create(let path):
            print("Create fileproviderProgress - filePath: \(path) - Progress: \(progress)")
//            DispatchQueue.main.async {
//                self.progressBar.setProgress(progress, animated: true)
//            }
        case .modify( let path):
            print("Modify fileproviderProgress - filePath: \(path) - Progress: \(progress)")
            DispatchQueue.main.async {
                self.hud?.progress = progress
            }
        case .remove(let path):
                print("Remove fileproviderProgress - filePath: \(path) - Progress: \(progress)")
            
        case .fetch(let path):
            print("Fetch fileproviderProgress - filePath: \(path) - Progress: \(progress)")
//            DispatchQueue.main.async {
//                self.progressBar.setProgress(progress, animated: true)
//            }
        default:
            break
        }
    }
}
