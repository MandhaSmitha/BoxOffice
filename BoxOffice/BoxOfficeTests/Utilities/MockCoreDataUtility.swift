//
//  MockCoreDataUtility.swift
//  BoxOfficeTests
//
//  Created by Smitha Mandha on 7/10/18.
//  Copyright © 2018 SmithaReddy. All rights reserved.
//

import CoreData

class MockCoreDataUtility {
    class func managedObjectContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Failure - Could not add In-memory persistentStore")
        }
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }
}
