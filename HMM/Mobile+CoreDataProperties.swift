//
//  Mobile+CoreDataProperties.swift
//  HMM
//
//  Created by JuanFelix on 4/23/16.
//  Copyright © 2016 JuanFelix. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Mobile {

    @NSManaged var name: String?
    @NSManaged var system: String?
    @NSManaged var owner: User?

}
