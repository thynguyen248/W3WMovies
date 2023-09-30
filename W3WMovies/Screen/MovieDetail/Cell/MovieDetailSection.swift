//
//  MovieDetailSection.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/30/23.
//

import Foundation

enum MovieDetailSectionType: Int {
    case main
}

struct MovieDetailSection: DiffableItem {
    var sectionType: MovieDetailSectionType
    var items: [MovieDetailCellItem] = []
    
    var identifier: String {
        return "\(sectionType.rawValue)"
    }
}

enum MovieDetailCellItem: Hashable {
    case media(item: MovieMediaCellItem)
    case overview(item: MovieOverviewCellItem)
}

struct MovieMediaCellItem: DiffableItem {
    let posterURL: URL?
    let coverURL: URL?
    let releaseDate: String?
    let voteAverage: String?
    
    var identifier: String {
        return posterURL?.absoluteString ?? UUID().uuidString
    }
}

extension MovieMediaCellItem {
    init(with movieModel: MovieModel) {
        self.releaseDate = movieModel.releaseDate?.toString()
        self.voteAverage = String(format: "%.1f", (movieModel.voteAverage ?? 0.0))
        self.posterURL = movieModel.posterURL
        self.coverURL = movieModel.coverURL
    }
}

struct MovieOverviewCellItem: DiffableItem {
    let title: String?
    let overview: String?
    
    var identifier: String {
        return (title ?? "") + (overview ?? "")
    }
}

extension MovieOverviewCellItem {
    init(with movieModel: MovieModel) {
        self.title = movieModel.title
        self.overview = movieModel.overview
    }
}
