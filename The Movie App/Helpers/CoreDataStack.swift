//
//  CoreDataStack.swift
//  The Movie App
//
//  Created by Nikhil Doppalapudi on 3/13/24.
//

import Foundation
import CoreData


class CoreDataStack {
    static let shared = CoreDataStack()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "MovieModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
