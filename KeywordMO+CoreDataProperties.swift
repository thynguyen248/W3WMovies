//
//  KeywordMO+CoreDataProperties.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 10/3/23.
//
//

import Foundation
import CoreData


extension KeywordMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeywordMO> {
        return NSFetchRequest<KeywordMO>(entityName: "KeywordMO")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var keyword: String?
    @NSManaged public var page: Int64
    @NSManaged public var movies: Set<MovieMO>?

}

// MARK: Generated accessors for movies
extension KeywordMO {

    @objc(addMoviesObject:)
    @NSManaged public func addToMovies(_ value: MovieMO)

    @objc(removeMoviesObject:)
    @NSManaged public func removeFromMovies(_ value: MovieMO)

    @objc(addMovies:)
    @NSManaged public func addToMovies(_ values: Set<MovieMO>)

    @objc(removeMovies:)
    @NSManaged public func removeFromMovies(_ values: Set<MovieMO>)

}

extension KeywordMO : Identifiable {
    func update(with keyword: String, page: Int) {
        self.identifier = "\(keyword) \(page)"
        self.keyword = keyword
        self.page = Int64(page)
    }
}
