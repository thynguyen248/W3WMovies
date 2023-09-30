//
//  MovieRepository.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Combine

protocol MovieReposistoryInterface {
    func getMovieList(page: Int) -> AnyPublisher<MovieResponseModel, AppError>
    func getMovieDetail(movieId: Int) -> AnyPublisher<MovieModel, AppError>
    func searchMovies(keyword: String, page: Int) -> AnyPublisher<MovieResponseModel, AppError>
}

final class MovieReposistory: MovieReposistoryInterface {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }
    
    func getMovieList(page: Int) -> AnyPublisher<MovieResponseModel, AppError> {
        return apiClient.getMovieList(page: page)
    }
    
    func getMovieDetail(movieId: Int) -> AnyPublisher<MovieModel, AppError> {
        return apiClient.getMovieDetail(movieId: movieId)
    }
    
    func searchMovies(keyword: String, page: Int) -> AnyPublisher<MovieResponseModel, AppError> {
        return apiClient.searchMovies(keyword: keyword, page: page)
    }
}
