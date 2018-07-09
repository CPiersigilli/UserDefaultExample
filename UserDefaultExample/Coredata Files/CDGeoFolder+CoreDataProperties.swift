//
//  CDGeoFolder+CoreDataProperties.swift
//  JSON-Example
//
//  Created by Marco Piersigilli on 23/01/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//
//

import Foundation
import CoreData


extension CDGeoFolder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDGeoFolder> {
        return NSFetchRequest<CDGeoFolder>(entityName: "CDGeoFolder")
    }

    @NSManaged public var isActive: Bool
    
    @NSManaged public var dataCreazione: Date
    @NSManaged public var nomeCantiere: String
    @NSManaged public var nomeCommittente: String
    @NSManaged public var note: String

    @NSManaged public var longitudine: Double
    @NSManaged public var latitudine: Double
    @NSManaged public var radiusCircle: Int16
}
