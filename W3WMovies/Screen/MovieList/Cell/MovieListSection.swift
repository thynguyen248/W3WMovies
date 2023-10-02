//
//  MovieListItem.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Foundation

enum MovieListSectionType: Int {
    case main
}

struct MovieListSection: DiffableItem {
    var sectionType: MovieListSectionType
    var items: [MovieListCellItem] = []
    var hasMoreData = false
    
    var identifier: String {
        return "\(sectionType.rawValue)"
    }
}

struct MovieListCellItem: DiffableItem {
    let identifier: String
    let movieId: Int
    let posterURL: URL?
    let title: String?
    let releaseDate: String?
    let voteAverage: String?
    let popularity: Double?
}

extension MovieListCellItem: Comparable {
    init(with movieModel: MovieModel, page: Int) {
        self.identifier = "\(movieModel.id) \(page)"
        self.movieId = movieModel.id
        self.posterURL = movieModel.posterURL
        self.title = movieModel.title
        self.releaseDate = movieModel.releaseDate?.toString()
        self.voteAverage = String(format: "%.1f", (movieModel.voteAverage ?? 0.0))
        self.popularity = movieModel.popularity
    }
    
    static func < (lhs: MovieListCellItem, rhs: MovieListCellItem) -> Bool {
        return (lhs.popularity ?? 0.0) < (rhs.popularity ?? 0.0)
    }
}
