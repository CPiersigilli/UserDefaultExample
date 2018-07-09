//
//  GeoFolderStruct.swift
//  ManageGeoFolder
//
//  Created by Cesare Piersigilli on 01/05/17.
//  Copyright © 2017 C. Piersigilli & Associati. All rights reserved.
//

import Foundation

struct LastUpdateStruct:Codable {
    let lastUpdate:Date
    
    enum CodingKeys : String, CodingKey {
        case lastUpdate = "Last_Update"
    }
}

// Assegna i valori alle componenti della struttura dati della LastUpdateStruct a partire dal data letto dal file
extension LastUpdateStruct {
    public init(from decoder: Decoder) throws {
        let myDecoder = try decoder.container(keyedBy: CodingKeys.self)
        
        // Trasforma la stringa in data secondo un formato definito da me
        let creationDateString = try myDecoder.decode(String.self, forKey: .lastUpdate)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = .withInternetDateTime
        if let lastUpdateFromJson = dateFormatter.date(from: creationDateString) {
            lastUpdate = lastUpdateFromJson
        } else {
            throw DecodingError.dataCorruptedError(forKey: .lastUpdate, in: myDecoder, debugDescription: "Il formato della data di creazione del geofolder non è del tipo: \(dateFormatter.formatOptions) in quanto è: \(creationDateString).")
        }
    }
}

// Estrae il file "\Last_UpDate.json" dal WebDav Server e lo converte (decode) in una LastUpdateStruct
func readLastUpdateFileFromWebDavServer(webdavFile:WebDAVFileProvider, pathFile:String, _ completion: @escaping (ResultType<LastUpdateStruct>) -> Void) {
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
            let jsonFromData =  try JSONDecoder().decode(LastUpdateStruct.self, from: data)
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

// Scrive il file "\Last_UpDate.json" nel WebDav Server con la data e l'ora attuali
func writeLastUpdateFileToWebDavServer(webdavFile:WebDAVFileProvider, pathFile:String, _ completion: @escaping (ResultType<LastUpdateStruct>) -> Void) {
    //  Definisce la nuova data ed ora da scrivere nel file Last_UpDate.json nel server webdav
    let lastUpdateStruct = LastUpdateStruct(lastUpdate: Date())
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    encoder.dateEncodingStrategy = .iso8601
    let data = try! encoder.encode(lastUpdateStruct)
    
    _ = webdavFile.writeContents(path: pathFile, contents: data, atomically: true, overwrite: true, completionHandler: { (error) in
        if error != nil {
            print("The file dataUltimaModifica was not created for the following error: \(String(describing: error))")
            completion(ResultType.Failure(e: error!))
        } else {
            print("The file \\Last_UpDate.json created.")
            completion(ResultType.Success(lastUpdateStruct))
        }
    })
}
