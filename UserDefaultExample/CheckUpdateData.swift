//
//  CheckUpdateData.swift
//  UserDefaultExample
//
//  Created by Marco Piersigilli on 06/02/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//

import Foundation
import UIKit

func checkUpdateDataFromWebdav( _ webdavFile:WebDAVFileProvider, pathFile: String, cartellaDefualt: String) -> Bool {
    var check = false
    var lastUpdateFromWebdavServerDate:Date? = nil
    var lastUpdateLocalDate:Date? = nil
    
    //    Verifica che la variabile "lastUpdate" contenuta nelle preferenze della app non sia nil
    let lastUpdateLocal = UserDefaults.standard.string(forKey: "lastUpdate")
    if lastUpdateLocal == nil {
        check = true
    }
    
    if !check {
        lastUpdateLocalDate = Date(fromString: lastUpdateLocal!, format: .custom(dateFormatLastUpdateLocal))
        var updateTime = Date()
        print("updateTime: \(updateTime)")
        if !check {
            let updateEvery = UserDefaults.standard.string(forKey: "updateEvery") ?? "Adesso"
            print("updateEvery: \(updateEvery) - lastUpdateLocalDate: \(lastUpdateLocalDate!)")
            switch updateEvery {
            case "Adesso":
                check = true
            case "Ogni ora":
                updateTime = lastUpdateLocalDate!.adjust(.hour, offset: 1)
                print("Ogni ora - updateTime: \(updateTime)")
            case "Ogni giorno":
                updateTime = lastUpdateLocalDate!.adjust(.day, offset: 1)
                print("Ogni giorno - updateTime: \(updateTime)")
            case "Ogni settimana":
                updateTime = lastUpdateLocalDate!.adjust(.week, offset: 1)
                print("Ogni settimana - updateTime: \(updateTime)")
            case "Mai":
                updateTime = Date().adjust(.minute, offset: 10)
                print("Mai - updateTime: \(updateTime)")
                check = false
            default:
                print("Nessun valore valido - updateTime: \(updateTime)")
                check = true
            }
            print("updateEvery: \(updateEvery) - updateTime: \(updateTime)")
        }
        if !check {
            if Date() >= updateTime {
                check = true
            }
        }
    }
    print("check: \(check)")
    let group = DispatchGroup()
    
    if check {
        group.enter()
        readLastUpdateFileFromWebDavServer(webdavFile: webdavFile, pathFile: pathFile, { (results) in
            switch results {
            case .Success(let lastUpdateFromJson):
                lastUpdateFromWebdavServerDate = lastUpdateFromJson.lastUpdate
                check = true
                print("1.2-Current Thread: \(Thread.current) - \(Thread.isMainThread).")
                print("Geofolder: \(String(describing: lastUpdateFromWebdavServerDate ?? nil))")
            case .Failure(let error):
                check = true
                print("1.3-Current Thread: \(Thread.current) - \(Thread.isMainThread) - \(error)")
                print("Non ho effettuato il decoding del file /geoFolderFile.json per l'errore: \(error).")
            }
            group.leave()
        })
        _ = group.wait(timeout: .now() + 10)
        
        // Verifica che lastUpdateLocalDate != nil e lastUpdateFromWebdavServerDate != nil, altrimenti la app va in crash
        if lastUpdateFromWebdavServerDate != nil && lastUpdateLocalDate != nil {
            if lastUpdateLocalDate! >= lastUpdateFromWebdavServerDate! {
                print("2-Current Thread: \(Thread.current) - \(Thread.isMainThread) - Non serve aggiornare i dati presenti nel telefono.")
                return check == false
            }
        } else {
            check = true
        }
    }
    
    if check {
        group.enter()
        print("3-Current Thread: \(Thread.current) - \(Thread.isMainThread)")
        DispatchQueue.main.async {
            CDController.shared.deleteAllGeoFolder()
        }
        
        webdavFile.contentsOfDirectory(path: cartellaDefualt, completionHandler: { (folders, error) in
            print("4-Current Thread: \(Thread.current) - \(Thread.isMainThread)")
            guard error==nil else {
                print("Non sono riuscito a caricare le cartelle contenute nella cartella di default per il seguente errore: \(String(describing: error?.localizedDescription)).")
                return
            }
            for folder in folders {
                print("Folder: \(folder.path).")
                if folder.isDirectory {
                    print("Step 4 - Is Folder: \(folder.path).")
                    let pathGeoFolderFile = folder.path + "/geoFolderFile.json"
                    group.enter()
                    readGeoFolderFileFromWebDavServer(webdavFile: webdavFile, pathFile: pathGeoFolderFile, { (results) in
                        print("4-Current Thread: \(Thread.current)")
                        switch results {
                        case .Success(let geoFolder):
                            print("Geofolder: \(geoFolder.nomeCartella)")
                            DispatchQueue.main.async {
                                CDController.shared.addGeoFolder(geoFolder: geoFolder)
                            }
                        case .Failure(let error):
                            print("Non ho effettuato il decoding del file /geoFolderFile.json per l'errore: \(error).")
                        }
                        group.leave()
                    })
                }
            }
            group.leave()
        })
        let end = group.wait(timeout: .now() + 10)
        let numFolder = CDController.shared.numberOfGeoFolder()
        let numFolderString = String(numFolder)
        print("6-Current Thread: \(Thread.current) - \(Thread.isMainThread) - NumFolder: \(numFolder) - End Function: \(end)")
        //    DispatchQueue.main.async {
        UserDefaults.standard.set(numFolderString, forKey: "numCartelle")
        //    }
    }
    
    return check
}

func upLoadMediaToServer () -> String {
    print("E' stata chiamata la func upLoadMediaToServer ().")
    var errore = ""
    let numMediaNow = CDController.shared.numberOfMedia()
    var notaStr = ""
    
//    numMedia.text = String(numMediaNow)
    print("Prima NumMediaNow = \(numMediaNow)")
    guard numMediaNow > 0 else {
        errore = "No Media"
        return errore
    }
    
    var webdavFile: WebDAVFileProvider?

    //  Estrae il media da caricare nella cartella specificata.
    let media = CDController.shared.fetchMedia()
    print("Media: \(media.pathURL!)")
    
    let imageName = media.pathURL?.components(separatedBy: "/")
    print("imagePath: \(imageName ?? ["Nil"]) - \(imageName?.count ?? 0).")
//    myImage.image = UIImage(data: media.mediaType! as Data)
    
    //  Verfica che le preferenze siano tutte presenti.
//    guard checkSettings(self) else {
//        return
//    }
    
    //  Estrae i valori delle preferenze e definisce i parametri necessari.
    let pref = readPreferences()
    let myWebdavURL = URL(string: pref.webdavURL)
    let credential = URLCredential(user: pref.username, password: pref.password, persistence: .forSession)
    
    webdavFile = WebDAVFileProvider(baseURL: myWebdavURL!, credential: credential)
    
    let group = DispatchGroup()
    group.enter()
    
    webdavFile?.isReachable(completionHandler: { (connesso, _) in
   
//    webdavFile?.isReachable(completionHandler: { (connesso) in
        guard connesso else {
            errore = "Non connesso"
            print("Non connesso.")
            return
        }
        print("Connesso.")
        
        group.enter()
        _ = webdavFile?.create(folder: pref.cartellaDefaultNoLoc, at: pref.cartellaDefault, completionHandler: { (error) in
            writeMediaToWebDavServer(webdavFile: webdavFile!, pathFile: media.pathURL!, imageData: media.mediaType! as Data, { (nota) in
                notaStr = nota
                errore = "OK"
                print("Nota: \(notaStr)")
                group.leave()
            })
        })
        
        print("Ho finito.")
        //            group.leave()
        
        _ = group.wait(timeout: .now()+5)
        
        guard notaStr.contains("senza errori.") else {
            //        guard notaStr.range(of: "senza errori.") != nil else {
            print("notaStr: \(notaStr)")
            return
        }
        group.enter()
    })
    
    _ = group.wait(timeout: .now()+5)
    print("Sto uscendo dalla upLoadMediaToServer ()")
    DispatchQueue.main.async {
        print("Sono nell'ultima parte.")
        if CDController.shared.deleteMedia(media: media) {
//            self.numMedia.text = String(numMediaNow - 1)
            print("Ho eliminato il Media salvato sul webdav server.")
        }
    }
    return errore
}
