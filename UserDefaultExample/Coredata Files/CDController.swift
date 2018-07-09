//
//  CDController.swift
//  JSON-Example
//
//  Created by Marco Piersigilli on 23/01/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
//import UIKit

class CDController {
    static let shared = CDController() // proprietà per ottenere la classe in modalità Singleton
    
    private var context: NSManagedObjectContext // riferimento al contenitore degli oggetti (ManagedObject) salvati in memoria
    
    private init() {
        // recupero l'istanza dell'AppDelegate dell'applicazione
        let application = UIApplication.shared.delegate as! AppDelegate
        // recupero il ManagedObjectContext dalla proprietà persistantContainer presente nell'App Delegate
        self.context = application.persistentContainer.viewContext
    }
    
    // MARK: Funzioni di controllo dei Media - Photo o Video

    //   Funzione per l'inserimento nel coredata di un media - Photo o Video
    func addNewMedia(nameMedia:String, pathURL:String, mediaType:Data) {
        let entity = NSEntityDescription.entity(forEntityName: "CDMedia", in: self.context)
        let newMedia = CDMedia(entity: entity!, insertInto: self.context)
        newMedia.name = nameMedia
        newMedia.timestamp = Date()
        newMedia.pathURL = pathURL
        newMedia.mediaType = mediaType as NSData
        do {
            try self.context.save()
        } catch let errore {
            print("Il salvataggio del nuovo media: \(newMedia.pathURL!) è fallito con l'errore: \(errore).")
        }
        print("NewMedia \(newMedia.pathURL!) salvato nel coredata correttamente")
    }
    
    //    Determina il numero dei MediaType
    func numberOfMedia() -> Int {
        var numMedia = 0
        let request: NSFetchRequest<CDMedia> = NSFetchRequest(entityName: "CDMedia")
        request.returnsObjectsAsFaults = false
        do {
            numMedia = try context.count(for: request)
        } catch {
            print ("Errore nel determinare il numero di Media in coredata.")
        }
        return numMedia
    }
    
    //   Funzione che ritorna un solo mediaType - Photo o Video dal coredata
    func fetchMedia() -> CDMedia {
        let request: NSFetchRequest<CDMedia> = NSFetchRequest(entityName: "CDMedia")
        request.fetchLimit = 1
        var media = CDMedia()
        var mediaArray = [CDMedia]()
        do {
            mediaArray = try self.context.fetch(request)
            let numMedia = mediaArray.count
            print("NumMedia: \(numMedia)")
            guard mediaArray.count > 0 else {print("Non ci sono media da leggere "); return media}
            media = mediaArray[0]
            print(media.pathURL ?? "Errore")
        } catch let errore {
            print("Problema esecuzione FetchRequest con l'errore: \n \(errore) \n")
        }
        return media
    }
    
    //   Funzione che ritorna tutti i mediaType - Photo o Video dal coredata
    func fetchAllMedia() -> [CDMedia] {
        let request: NSFetchRequest<CDMedia> = NSFetchRequest(entityName: "CDMedia")
        var mediaArray = [CDMedia]()
        do {
            mediaArray = try self.context.fetch(request)
            guard mediaArray.count > 0 else {
                return mediaArray}
        } catch let errore {
            print("Problema esecuzione FetchRequest con l'errore: \n \(errore) \n")
        }
        return mediaArray
    }
    
    //   Funzione che elimina un mediaType - Photo o Video dal coredata
    func deleteMedia(media:CDMedia) -> Bool {
        print("1-func deleteMedia: \(numberOfMedia())")
        context.delete(media)
        do {
            try self.context.save()
            print("2-func deleteMedia: \(numberOfMedia())")
            return true
        } catch let errore {
            print("L'eliminazione del CDMedia: \(media.pathURL!) è fallito con l'errore: \(errore).")
            return false
        }
    }
    
    //   Funzione che raggruppa i mediaType - Photo o Video - contenuti nel coredata per giorno
    func groupMediaForDay() -> NSFetchedResultsController<CDMedia> {
        var fetchedController: NSFetchedResultsController<CDMedia>!
        let request: NSFetchRequest<CDMedia> = CDMedia.fetchRequest()
        let sort = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [sort]
        fetchedController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: "sectionName", cacheName: nil)
//        fetchedController.delegate = self
        do {
            try fetchedController.performFetch()
        } catch {
            print("Error: \(error.localizedDescription).")
        }
        return fetchedController
    }

    // MARK: Funzioni di controllo dei GeoFolder
    
    //   Funzione che determina l'eventuale geofolder contenuto nel coredata che contiene la posizione del media - Photo o Video
    func foundGeoFolder(latitudine:Double!, longitudine:Double!) -> String {
        let folderMedia = UserDefaults.standard.string(forKey: "cartellaDefaultNoLoc") ?? folderNoLoc
        guard !(latitudine == nil && longitudine == nil) else {
            print("Latitudine e longitudine uguali a zero.")
            return folderMedia
        }
        let locationMedia = CLLocation(latitude: latitudine!, longitude: longitudine!)
        var geoFolderArray = [CDGeoFolder]()
        let request: NSFetchRequest<CDGeoFolder> = NSFetchRequest(entityName: "CDGeoFolder")
        do {
            geoFolderArray = try self.context.fetch(request)
            guard geoFolderArray.count > 0 else {print("Non ci sono GeoFolder da leggere "); return ""}
            for geoFolder in geoFolderArray {
                let locationGeoFolder = CLLocation(latitude: geoFolder.latitudine, longitude: geoFolder.longitudine)
                let distanceInMeters = locationMedia.distance(from: locationGeoFolder)
                print("Distanza in metri: \(distanceInMeters)")
                if distanceInMeters <= 100 {
                    return geoFolder.nomeCantiere 
                }
            }
        } catch let errore {
            print("[CDC] Problema esecuzione FetchRequest")
            print("  Stampo l'errore: \n \(errore) \n")
            return folderMedia
        }
        return folderMedia
    }

    //   Memorizza una GeoFolder
    func addGeoFolder(geoFolder:GeoFolderStruct) {
        print("addGeoFolder")
        let entity = NSEntityDescription.entity(forEntityName: "CDGeoFolder", in: context)
        let newGeoFolder = CDGeoFolder(entity: entity!, insertInto: self.context)
        newGeoFolder.isActive = geoFolder.isActive
        
        newGeoFolder.dataCreazione = geoFolder.dataCreazione
        newGeoFolder.nomeCantiere = geoFolder.nomeCartella
        newGeoFolder.nomeCommittente = geoFolder.nomeCommittente
        newGeoFolder.note = geoFolder.note
        
        newGeoFolder.latitudine = geoFolder.latitudine
        newGeoFolder.longitudine = geoFolder.longitudine
        newGeoFolder.radiusCircle = geoFolder.radiusCircle
        do {
            try self.context.save()
        } catch let errore {
            print("Il salvataggio della GeoFolder: \(newGeoFolder.nomeCantiere) è fallito con l'errore: \(errore).")
        }
        print("GeoFolder \(newGeoFolder.nomeCantiere) salvato in memoria correttamente")
    }

    //    Determina il numero delle GeoFolder
    func numberOfGeoFolder() -> Int {
        var numGeoFolder = 0
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CDGeoFolder")
        do {
            numGeoFolder = try context.count(for: fetch)
        } catch {
            print ("Errore nel determinare il numero di GeoFolder presenti in coredata.")
        }
        return numGeoFolder
    }
    
    //    Cancella tutte le GeoFolder
    func deleteAllGeoFolder() {
        print("deleteAllGeoFolder")
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CDGeoFolder")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("Errore nella eliminazione dei GeoFolder in coredata.")
        }
    }
    
    //    Stampa tutte le GeoFolder
    func loadAllGeoFolder() {
        print("Recupero tutte le GeoFolder dal context ")
        let request: NSFetchRequest<CDGeoFolder> = NSFetchRequest(entityName: "CDGeoFolder")
        request.returnsObjectsAsFaults = false
        _ = self.loadGeoFolderFromFetchRequest(request: request)
    }
    
    //  La funzione restituisce un array di GeoFolder dopo aver eseguito la request
    private func loadGeoFolderFromFetchRequest(request: NSFetchRequest<CDGeoFolder>) -> [CDGeoFolder] {
        var array = [CDGeoFolder]()
        do {
            array = try self.context.fetch(request)

            guard array.count > 0 else {print("Non ci sono GeoFolder da leggere "); return []}

            for x in array {
                print("\(String(describing: x.dataCreazione)) \(String(describing: x.nomeCantiere)) \(String(describing: x.nomeCommittente)) \(x.isActive) ")
            }

        } catch let errore {
            print("[CDC] Problema esecuzione FetchRequest")
            print("  Stampo l'errore: \n \(errore) \n")
        }

        return array
    }
}

