//
//  MovieMO+CoreDataProperties.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 10/1/23.
//
//

import Foundation
import CoreData


extension MovieMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieMO> {
        return NSFetchRequest<MovieMO>(entityName: "MovieMO")
    }

    @NSManaged public var identifier: String
    @NSManaged public var movieId: Int64
    @NSManaged public var title: String?
    @NSManaged public var overview: String?
    @NSManaged public var voteAverage: Double
    @NSManaged public var popularity: Double
    @NSManaged public var releaseDate: Date?
    @NSManaged public var posterPath: String?
    @NSManaged public var videoKey: String?
    @NSManaged public var keywords: Set<KeywordMO>?

}

// MARK: Generated accessors for keywords
extension MovieMO {

    @objc(addKeywordsObject:)
    @NSManaged public func addToKeywords(_ value: KeywordMO)

    @objc(removeKeywordsObject:)
    @NSManaged public func removeFromKeywords(_ value: KeywordMO)

    @objc(addKeywords:)
    @NSManaged public func addToKeywords(_ values: Set<KeywordMO>)

    @objc(removeKeywords:)
    @NSManaged public func removeFromKeywords(_ values: Set<KeywordMO>)

}

extension MovieMO : Identifiable {
    func update(with movieModel: MovieModel, page: Int) {
        self.identifier = "\(movieModel.id) \(page)"
        self.movieId = Int64(movieModel.id)
        self.title = movieModel.title
        self.overview = movieModel.overview
        self.voteAverage = movieModel.voteAverage ?? 0.0
        self.popularity = movieModel.popularity ?? 0.0
        self.releaseDate = movieModel.releaseDate
        self.posterPath = movieModel.posterPath
        self.videoKey = movieModel.videos?.results?.first?.key
    }
    
    var movieModel: MovieModel {
        return MovieModel(id: Int(movieId), posterPath: posterPath, title: title, overview: overview, voteAverage: voteAverage, popularity: popularity, videos: VideoResponseModel(results: [VideoModel(key: videoKey)]), releaseDate: releaseDate)
    }
}
