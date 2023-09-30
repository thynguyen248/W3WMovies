//
//  APIClient+movieList.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Combine

struct MovieListRequest: Request {
    typealias ReturnType = MovieResponseModel
    let page: Int
    var path: String { return "/trending/movie/day" }
    var queryParams: [String : Any]? {
        return ["page": page]
    }
}

extension APIClient {
    func getMovieList(page: Int) -> AnyPublisher<MovieResponseModel, AppError> {
        let movieListRequest = MovieListRequest(page: page)
        return request(movieListRequest)
    }
}
