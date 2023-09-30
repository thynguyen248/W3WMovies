//
//  APIClient+movieDetail.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Combine

struct MovieDetailRequest: Request {
    typealias ReturnType = MovieModel
    let movieId: Int
    var path: String { return "/movie/\(movieId)" }
    var queryParams: [String : Any]? {
        return ["append_to_response": "videos"]
    }
}

extension APIClient {
    func getMovieDetail(movieId: Int) -> AnyPublisher<MovieModel, AppError> {
        let movieDetailRequest = MovieDetailRequest(movieId: movieId)
        return request(movieDetailRequest)
    }
}
