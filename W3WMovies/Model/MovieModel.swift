//
//  MovieModel.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Foundation

struct MovieResponseModel: Decodable {
    let results: [MovieModel]?
    let page: Int?
    let totalPages: Int?
}

struct MovieModel: Decodable {
    let id: Int
    let posterPath: String?
    let title: String?
    let overview: String?
    let voteAverage: Double?
    let popularity: Double?
    let videos: VideoResponseModel?
    @DateWrapper var releaseDate: Date?
    
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: String(format: APIConstants.posterURL, posterPath))
    }
    
    var coverURL: URL? {
        guard let videoKey = videos?.results?.first?.key else { return nil }
        return URL(string: String(format: APIConstants.videoThumbnailURL, videoKey))
    }
    
    var releaseDateString: String {
        return releaseDate?.toString() ?? ""
    }
}

@propertyWrapper
struct DateWrapper: Codable {
    var wrappedValue: Date?
    
    init(wrappedValue value: Date?) {
        self.wrappedValue = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Date.self) {
            wrappedValue = value
        }
    }
    
    func encode(to encoder: Encoder) throws {
    }
}
