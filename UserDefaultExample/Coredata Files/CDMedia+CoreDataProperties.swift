//
//  CDMedia+CoreDataProperties.swift
//  UserDefaultExample
//
//  Created by Marco Piersigilli on 24/03/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//
//

import Foundation
import CoreData


extension CDMedia {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDMedia> {
        return NSFetchRequest<CDMedia>(entityName: "CDMedia")
    }

    @NSManaged public var mediaType: NSData?
    @NSManaged public var pathURL: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var name: String?
    @objc public var sectionName: String? {
        get {
            var timestampString = ""
            if let timestamp = timestamp {
                let timestampDate = timestamp
                if timestamp.compare(.isToday) {
                    timestampString = "Oggi "
                }
                if timestamp.compare(.isYesterday) {
                    timestampString = "Ieri "
                }
                timestampString += timestampDate.toString(format: .custom(dateFormatToCoreData))
                print("timestamp: \(timestampString)")
                return timestampString
            } else {
                timestampString = "Nessuna Data"
                print("Nessuna Data")
                return timestampString
            }
        }
    }



}
