//
//  Photo+CoreDataProperties.swift
//  Photorama
//
//  Created by Carolina Salamanca on 7/16/20.
//  Copyright © 2020 Carolina Salamanca. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var photoID: String?
    @NSManaged public var title: String?
    @NSManaged public var dateTaken: Date?
    @NSManaged public var remoteURL: URL?

}
