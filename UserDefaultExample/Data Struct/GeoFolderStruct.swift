//
//  GeoFolderStruct.swift
//  ManageGeoFolder
//
//  Created by Cesare Piersigilli on 01/05/17.
//  Copyright © 2017 C. Piersigilli & Associati. All rights reserved.
//

import Foundation

struct GeoFolderStruct:Codable {
    let isActive:Bool
    
    let dataCreazione:Date
    let nomeCartella:String
    let nomeCommittente:String
    let note:String
    
    
    let latitudine: Double
    let longitudine: Double
    let radiusCircle: Int16
    
    enum CodingKeys : String, CodingKey {
        case isActive
        
        case dataCreazione
        case nomeCartella
        case nomeCommittente
        case note
        
        case latitudine
        case longitudine
        case radiusCircle
    }
}

// Assegna i valori alle componenti della struttura dati della GeoFolder a partire dal data letto dal file
extension GeoFolderStruct {
public init(from decoder: Decoder) throws {
    let geoFolder = try decoder.container(keyedBy: CodingKeys.self)
    isActive = try geoFolder.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
    
    nomeCartella = try geoFolder.decode(String.self, forKey: .nomeCartella)
    nomeCommittente = try geoFolder.decodeIfPresent(String.self, forKey: .nomeCommittente) ?? ""
    note = try geoFolder.decodeIfPresent(String.self, forKey: .note) ?? ""
    
    latitudine = try geoFolder.decode(Double.self, forKey: .latitudine)
    longitudine = try geoFolder.decode(Double.self, forKey: .longitudine)
    radiusCircle = try geoFolder.decodeIfPresent(Int16.self, forKey: .radiusCircle) ?? 30
    
    // Trasforma la stringa in data secondo un formato definito da me
    let creationDateString = try geoFolder.decode(String.self, forKey: .dataCreazione)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'_'HH:mm:ss.SSS"
    if let dataCreazioneFromJson = dateFormatter.date(from: creationDateString) {
        dataCreazione = dataCreazioneFromJson
    } else {
        throw DecodingError.dataCorruptedError(forKey: .dataCreazione, in: geoFolder, debugDescription: "Il formato della data di creazione del geofolder non è del tipo: \(dateFormatter.dateFormat!) in quanto è: \(creationDateString).")
        }
    }
}

// Estrae il file "/geoFolderFile.json" dal WebDav Server e lo converte (decode) in un GeoFolderStruct
func readGeoFolderFileFromWebDavServer(webdavFile:WebDAVFileProvider, pathFile:String, _ completion: @escaping (ResultType<GeoFolderStruct>) -> Void) {
    webdavFile.contents(path: pathFile) { (data, error) in
        guard error == nil else {
            completion(ResultType.Failure(e: error!))
            return
        }
        
        guard let data = data else {
            completion(ResultType.Failure(e: error!))
            return
        }
        
        do {
            let jsonFromData =  try JSONDecoder().decode(GeoFolderStruct.self, from: data)
            completion(ResultType.Success(jsonFromData))
        } catch DecodingError.dataCorrupted(let context) {
            completion(ResultType.Failure(e: DecodingError.dataCorrupted(context)))
        } catch DecodingError.keyNotFound(let key, let context) {
            completion(ResultType.Failure(e: DecodingError.keyNotFound(key, context)))
        } catch DecodingError.typeMismatch(let type, let context) {
            completion(ResultType.Failure(e: DecodingError.typeMismatch(type, context)))
        } catch DecodingError.valueNotFound(let value, let context) {
            completion(ResultType.Failure(e: DecodingError.valueNotFound(value, context)))
        } catch {
            completion(ResultType.Failure(e:JSONDecodingError.unknownError))
        }
    }
}

//Funzione che salva nel webdav server un media alla volta tra quelli presenti nel coredata
func writeMediaToWebDavServer(webdavFile:WebDAVFileProvider, pathFile:String, imageData:Data, _ completion: @escaping (String) -> Void) {
    _ = webdavFile.writeContents(path: pathFile, contents: imageData, atomically: true, overwrite: true) { (error) in
        guard error == nil else {
            completion(error as! String)
            return
        }
        completion("\(pathFile) salvata correttamente, senza errori.")
    }
}

//enum CodingKeys : String, CodingKey {
//    case isActive
//
//    case dataCreazione = "Data_Creazione"
//    case nomeCartella = "Nome_Cantiere"
//    case nomeCommittente = "Nome_Committente"
//    case note = "Note"
//
//    case latitudine
//    case longitudine
//    case radiusCircle = "Raggio_Interferenza"
//}
