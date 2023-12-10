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
        let predicate = NSPredicate(format: "ANY keywords.keyword = %@ AND ANY keywords.page = %@", keyword, "\(page)")
        return fetch(objectType: MovieMO.self, predicate: predicate)
            .map { $0.map { $0.movieModel } }
            .eraseToAnyPublisher()
    }
    
    func saveMovies(_ movies: [MovieModel], keyword: String, page: Int) -> AnyPublisher<[MovieModel], AppError> {
        let context = newBackgroundContext
        let newIds = Set(movies.map { "\($0.id) \(page)" })
        
        /// Get existing keyword or insert new keyword
        var currentKeywordMOs = Set<KeywordMO>()
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
            currentKeywordMOs = Set(existingKeywords)
        } else {
            let keywordMO = KeywordMO(context: context)
            keywordMO.update(with: keyword, page: page)
            currentKeywordMOs.insert(keywordMO)
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
        existingMovieMOs?.forEach { movieMO in
            if newIds.contains(movieMO.identifier),
               let movie = movies.first(where: { $0.id == movieMO.movieId }) {
                movieMO.update(with: movie, page: page)
            } else {
                movieMO.removeFromKeywords(currentKeywordMOs)
            }
        }
        
        // Delete movie that's not linked to any keyword
        let objectsToRemove = existingMovieMOs?.filter { $0.keywords?.isEmpty ?? true }.map { $0.objectID } ?? []
        if !objectsToRemove.isEmpty {
            let batchDeleteRequest = NSBatchDeleteRequest(objectIDs: objectsToRemove)
            _ = try? context.execute(batchDeleteRequest)
        }
        
        // Insert new movie
        var newMovieMOs: [MovieMO] = []
        let oldIds = Set(existingMovieMOs?.compactMap { $0.identifier } ?? [])
        movies.forEach { movie in
            if !oldIds.contains("\(movie.id) \(page)") {
                let movieMO = MovieMO(context: context)
                movieMO.update(with: movie, page: page)
                if let keyword = currentKeywordMOs.first(where: { $0.page == page }) {
                    movieMO.addToKeywords(keyword)
                }
                newMovieMOs.append(movieMO)
            }
        }
        
        return saveContext(context)
            .map { result in
                return result ? movies : []
            }
            .eraseToAnyPublisher()
    }
}
