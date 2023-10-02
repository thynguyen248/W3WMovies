//
//  CoreDataStack+movies.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 10/1/23.
//

import CoreData
import Combine

extension CoreDataStack: DBHandlerInterface {
    func getMovies(keyword: String, page: Int) -> AnyPublisher<[MovieModel], AppError> {
        let predicate1 = NSPredicate(format: "ANY keywords.keyword = %@", keyword)
        let predicate2 = NSPredicate(format: "ANY keywords.page = %@", "\(page)")
        let predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
        return fetch(objectType: MovieMO.self, predicate: predicate)
            .map { $0.map { $0.movieModel } }
            .eraseToAnyPublisher()
    }
    
    func saveMovies(_ movies: [MovieModel], keyword: String, page: Int) -> AnyPublisher<[MovieModel], AppError> {
        let context = newBackgroundContext
        let newIds = Set(movies.map { $0.id })
        
        /// Get existing keyword or insert new keyword
        var currentKeywordMOs: [KeywordMO] = []
        let keywordsRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: KeywordMO.self))
        let keywordsPredicate: NSPredicate
        let keywordsPredicate1 = NSPredicate(format: "keyword = %@", keyword)
        let keywordsPredicate2 = NSPredicate(format: "page = %@", "\(page)")
        if page == 1 {
            keywordsPredicate = keywordsPredicate1
        } else {
            keywordsPredicate = NSCompoundPredicate.init(type: .and, subpredicates: [keywordsPredicate1, keywordsPredicate2])
        }
        keywordsRequest.predicate = keywordsPredicate
        let existingKeywords = (try? context.fetch(keywordsRequest) as? [KeywordMO]) ?? []
        if !existingKeywords.isEmpty {
            currentKeywordMOs = existingKeywords
        } else {
            let keywordMO = KeywordMO(context: context)
            keywordMO.update(with: keyword, page: page)
            try? context.save()
            let changes: [AnyHashable: Any] = [NSInsertedObjectsKey: [keywordMO.objectID]]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            currentKeywordMOs.append(keywordMO)
        }
        
        /// Update existing movie or insert new movie
        let moviesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: MovieMO.self))
        let moviesPredicate1 = NSPredicate(format: "ANY keywords.keyword = %@", keyword)
        let moviesPredicate2 = NSPredicate(format: "ANY keywords.page = %@", "\(page)")
        let moviesPredicate: NSPredicate
        if page == 1 {
            moviesPredicate = moviesPredicate1
        } else {
            moviesPredicate = NSCompoundPredicate.init(type: .and, subpredicates: [moviesPredicate1, moviesPredicate2])
        }
        moviesRequest.predicate = moviesPredicate
        let existingMovieMOs = try? context.fetch(moviesRequest) as? [MovieMO]
        
        // Update existing movies
        var objectsToUpdate = [NSManagedObjectID]()
        existingMovieMOs?.forEach({ movieMO in
            if newIds.contains(Int(movieMO.movieId)),
                let movie = movies.first(where: { $0.id == movieMO.movieId }),
               // Extra checking for duplicated movies in different pages
                movieMO.identifier == "\(movie.id) \(page)" {
                movieMO.update(with: movie, page: page)
            } else {
                currentKeywordMOs.forEach { keyword in
                    movieMO.removeFromKeywords(keyword)
                }
            }
            objectsToUpdate.append(movieMO.objectID)
        })
        if !objectsToUpdate.isEmpty {
            let changes: [AnyHashable: Any] = [NSUpdatedObjectsKey: objectsToUpdate]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
        }
        
        // Delete movie that's not linked to any keyword
        let objectsToRemove = existingMovieMOs?.filter { $0.keywords?.isEmpty ?? true }.map { $0.objectID } ?? []
        if !objectsToRemove.isEmpty {
            let batchDeleteRequest = NSBatchDeleteRequest(objectIDs: objectsToRemove)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            let deleteResult = try? context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult?.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
        }
        
        // Insert new movie
        var newMovieMOs: [MovieMO] = []
        let oldIds = Set(existingMovieMOs?.compactMap { $0.movieId } ?? [])
        movies.forEach { movie in
            if !oldIds.contains(Int64(movie.id)) {
                let movieMO = MovieMO(context: context)
                movieMO.update(with: movie, page: page)
                if let keyword = currentKeywordMOs.first(where: { $0.page == page }) {
                    movieMO.addToKeywords(keyword)
                }
                newMovieMOs.append(movieMO)
            }
        }
        
        return save(objectType: MovieMO.self, objects: newMovieMOs)
            .map { result in
                return result ? movies : []
            }
            .eraseToAnyPublisher()
    }
}
