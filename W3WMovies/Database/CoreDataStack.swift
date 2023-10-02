//
//  CoreDataStack.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/30/23.
//

import CoreData
import Combine

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    private let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "W3WMovies")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    var mainContext: NSManagedObjectContext {
        container.viewContext
    }
    
    lazy var newBackgroundContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }()
}

extension CoreDataStack {
    func fetch<T: NSManagedObject>(objectType: T.Type,
                                   predicate: NSPredicate? = nil,
                                   sortDescriptor: NSSortDescriptor? = nil,
                                   limit: Int? = nil,
                                   offset: Int? = nil)
    -> AnyPublisher<[T], AppError> {
        return Future() { [weak self] promise in
            let request = NSFetchRequest<T>(entityName: String(describing: T.self))
            request.predicate = predicate
            if let sortDescriptor = sortDescriptor {
                request.sortDescriptors = [sortDescriptor]
            }
            if let limit = limit, let offset = offset {
                request.fetchLimit = limit
                request.fetchOffset = offset
            }
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: request) { result in
                let result = result.finalResult ?? []
                promise(.success(result))
            }
            do {
                try self?.mainContext.execute(asynchronousFetchRequest)
            } catch {
                promise(.failure(AppError.dbFetchError(error.localizedDescription)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func save<T: NSManagedObject>(objectType: T.Type, objects: [T]) -> AnyPublisher<Bool, AppError> {
        return Future() { promise in
            let context = objects.first?.managedObjectContext
            context?.performAndWait {
                if context?.hasChanges == true {
                    do {
                        try context?.save()
                        promise(.success((true)))
                    } catch {
                        promise(.failure(AppError.dbInsertError(error.localizedDescription)))
                    }
                } else {
                    promise(.success((false)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
