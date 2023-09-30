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

struct MovieListSection: Hashable {
    var sectionType: MovieListSectionType
    var items: [MovieListCellItem] = []
    var hasMoreData = false
    
    var identifier: String {
        return "\(sectionType.rawValue)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: MovieListSection, rhs: MovieListSection) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

struct MovieListCellItem: DiffableItem {
    let identifier: String
    let movieId: Int
    let posterURL: URL?
    let title: String?
    let releaseDate: String?
    let voteAverage: String?
}

extension MovieListCellItem {
    init(with movieModel: MovieModel, page: Int) {
        self.identifier = "\(movieModel.id) \(page)"
        self.movieId = movieModel.id
        self.title = movieModel.title
        self.releaseDate = movieModel.releaseDate?.toString()
        self.voteAverage = String(format: "%.1f", (movieModel.voteAverage ?? 0.0))
        self.posterURL = movieModel.posterURL
    }
}
