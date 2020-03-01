//
//  CNSManagedObjectFetchResultsSnapshot.swift
//  CombineUI
//
//  Created by pranjal on 2/29/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

import Combine
import CoreData

public class CNSManagedObjectFetchedResultsController<Object: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    let fetchedResultsController: NSFetchedResultsController<Object>
    let subject = CurrentValueSubject<[Object], Error>([])
    
    public var fetchedObjectsPublisher: AnyPublisher<[Object], Error> {
        subject.eraseToAnyPublisher()
    }
    
    public init(fetchRequest: NSFetchRequest<Object>, context: NSManagedObjectContext) {
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
                
        super.init()
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            subject.send(completion: .failure(error))
        }
        
        self.fetchedResultsController.delegate = self
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let objects = controller.fetchedObjects as? [Object] ?? []
        subject.send(objects)
    }
}
