//
//  ViewController.swift
//  UserDefaultExample
//
//  Created by Marco Piersigilli on 06/02/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var lastUpdateFromIphone: UILabel!
    @IBOutlet weak var lastUpdateFromServerLabel: UILabel!
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var numMedia: UILabel!
    
    var webdavFile: WebDAVFileProvider?
    var managerPosizione: CLLocationManager!
    let progressBar = UIProgressView()
    let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)

    var myImageArray = ["Melbourne.jpg","Milano.jpg","Firenze.jpg","Singapore.jpg"]
    
    
    
    //Funzione che carica il media sul coredata
    @IBAction func takeMedia(_ sender: UIButton) {
        let random = Int(arc4random_uniform(UInt32(myImageArray.count)))
        let mediaToLoad = myImageArray[random]
        myImage.image = UIImage(named: mediaToLoad)
        
        //  Verfica che le preferenze siano tutte presenti.
        guard checkSettings(self) else {
            return
        }
        //  Estrae i valori delle preferenze e definisce i parametri necessari.
        let pref = readPreferences()
                
        print("lat: \(managerPosizione.location?.coordinate.latitude ?? 0.00) - long: \(managerPosizione.location?.coordinate.longitude ?? 0.00)")
        let lat = managerPosizione.location?.coordinate.latitude
        let lon = managerPosizione.location?.coordinate.longitude
        let geoFolderNomeCartella = CDController.shared.foundGeoFolder(latitudine: lat, longitudine: lon)

        let nameMedia = mediaName(nomeCartella: geoFolderNomeCartella)
        let pathURL = pref.cartellaDefault + geoFolderNomeCartella + "/" + nameMedia
        print("pathURL: \(pathURL)")
        if let img = UIImage(named: mediaToLoad) {
            let dataImage = UIImageJPEGRepresentation(img, 1)
            CDController.shared.addNewMedia(nameMedia: nameMedia, pathURL: pathURL, mediaType: dataImage!)
        }
        numMedia.text = String(CDController.shared.numberOfMedia())
    }
    
    //Funzione che aggiorna la data dell'ultimo salvataggio nel webdav server
    @IBAction func lastUpdateServerButton(_ sender: UIButton) {
        
        //  Verfica che le preferenze siano tutte presenti.
        guard checkSettings(self) else {
            return
        }
        //  Estrae i valori delle preferenze e definisce i parametri necessari.
        let pref = readPreferences()
        print(pref)
        let pathDataUltModFile = pref.cartellaDefault + "Last_UpDate.json"
        print(pathDataUltModFile)
        let myWebdavURL = URL(string: pref.webdavURL)
        let credential = URLCredential(user: pref.username, password: pref.password, persistence: .forSession)
        webdavFile = WebDAVFileProvider(baseURL: myWebdavURL!, credential: credential)

        writeLastUpdateFileToWebDavServer(webdavFile: webdavFile!, pathFile: pathDataUltModFile) { (results) in
            switch results {
            case .Success(let lastUpdateFromJson):
                let lastUpdateToWebdavServerDate = lastUpdateFromJson.lastUpdate
                print("1.2-Current Thread: \(Thread.current) - \(Thread.isMainThread).")
                print("Last_UpDate.json: \(String(describing: lastUpdateToWebdavServerDate))")
                DispatchQueue.main.async {
                    self.lastUpdateFromIphone.text = UserDefaults.standard.string(forKey: "lastUpdate")
                    self.lastUpdateFromServerLabel.text = lastUpdateToWebdavServerDate.toString(format: .custom(dateFormatLastUpdateLocal))
                    print("The file was created.")
                }
            case .Failure(let error):
                print("1.3-Current Thread: \(Thread.current) - \(Thread.isMainThread) - \(error)")
                print("Non ho effettuato il decoding del file /geoFolderFile.json per l'errore: \(error).")
                self.lastUpdateFromServerLabel.text = (error as! String)
                self.lastUpdateFromIphone.text = UserDefaults.standard.string(forKey: "lastUpdate")
            }
        }
    }
    
    @IBAction func uploadMedia(_ sender: UIButton) {
        print("func uploadMedia")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("viewDidLoad")
        logw("viewDidLoad")
        numMedia.text = String(CDController.shared.numberOfMedia())
        self.managerPosizione = CLLocationManager()
        managerPosizione.delegate = self
        managerPosizione.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        managerPosizione.requestWhenInUseAuthorization()
        managerPosizione.startUpdatingLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        logw("viewWillAppear")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        logw("viewWillDisappear")
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIApplicationDidBecomeActive,
                                                  object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        logw("viewDidAppear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
        logw("viewDidDisappear")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    Aggiorna l'UI di ritorno dal background
    @objc func applicationDidBecomeActive() {
        print("Ci sono riuscito l'applicazione aggiornerà l'UI.")
        checkPreferencesButton()
    }

    func checkPreferencesButton() {
        //  Verifica che le preferenze siano tutte presenti, ma non riesce a controllare che siano corrette.
            guard checkSettings(self) else {
                return
            }
        
        //  Estrae i valori delle preferenze e definisce i parametri necessari.
        let pref = readPreferences()
        print(pref)
        let pathDataUltModFile = pref.cartellaDefault + "Last_UpDate.json"
        print(pathDataUltModFile)
        let myWebdavURL = URL(string: pref.webdavURL)
        
        let credential = URLCredential(user: pref.username, password: pref.password, persistence: .forSession)
        
        webdavFile = WebDAVFileProvider(baseURL: myWebdavURL!, credential: credential)
        
//        alertPresentDownloadIndicatorView(self)
        
        webdavFile?.isReachable(completionHandler: { (connesso, _) in
            guard connesso else {
                print("Non connesso.")
//                alertDismissIndicatorView(self)
                return
            }
            print("Connesso.")
            if checkUpdateDataFromWebdav(self.webdavFile!, pathFile: pathDataUltModFile, cartellaDefualt: pref.cartellaDefault) {
                alertPresentDownloadIndicatorView(self)
                writeLastUpdateFileToWebDavServer(webdavFile: self.webdavFile!, pathFile: pathDataUltModFile) { (results) in
                    switch results {
                    case .Success(let lastUpdateFromJson):
                        let lastUpdateToWebdavServerDate = lastUpdateFromJson.lastUpdate
                        print("1.2-Current Thread: \(Thread.current) - \(Thread.isMainThread).")
                        print("Last_UpDate.json: \(String(describing: lastUpdateToWebdavServerDate))")
                        DispatchQueue.main.async {
                            // Data contenuta nel Webdav Server
                            let nowDateString = lastUpdateToWebdavServerDate.toString(format: .custom(dateFormatLastUpdateLocal))
                            // Data da settare nelle preferenze della App: "lastUpdate"
                            let nowDateStringLocal = Date().toString(format: .custom(dateFormatLastUpdateLocal))
                            UserDefaults.standard.set(nowDateStringLocal, forKey: "lastUpdate")
                            self.lastUpdateFromIphone.text = nowDateString
                            self.lastUpdateFromServerLabel.text = nowDateString
                            print("The file was created.")
                        }
                    case .Failure(let error):
                        print("1.3-Current Thread: \(Thread.current) - \(Thread.isMainThread) - \(error)")
                        print("Non ho effettuato il decoding del file /geoFolderFile.json per l'errore: \(error).")
                    }
                }
                print("Serve aggiornare i dati.")
                DispatchQueue.main.async {
                    alertDismissIndicatorView(self)
                }
            } else {
                print("Non serve aggiornare i dati.")
                DispatchQueue.main.async {
                    alertDismissIndicatorView(self)
                }
            }            
            print("Ho finito.")
        })
    }
}

