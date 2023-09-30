//
//  APIClient+searching.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/29/23.
//

import Combine

struct SearchMoviesRequest: Request {
    typealias ReturnType = MovieResponseModel
    let keyword: String
    let page: Int
    var path: String { return "/search/movie" }
    var queryParams: [String : Any]? {
        return ["query": keyword, "page": page]
    }
}

extension APIClient {
    func searchMovies(keyword: String, page: Int) -> AnyPublisher<MovieResponseModel, AppError> {
        let movieListRequest = SearchMoviesRequest(keyword: keyword, page: page)
        return request(movieListRequest)
    }
}
