//
//  MovieRepository.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Combine

protocol MovieReposistoryInterface {
    func getMovieList(isReachable: Bool, keyword: String, page: Int) -> AnyPublisher<MovieResponseModel, AppError>
    func getMovieDetail(isReachable: Bool, movieId: Int) -> AnyPublisher<MovieModel, AppError>
}

final class MovieReposistory: MovieReposistoryInterface {
    private let apiClient: APIClientInterface
    private let dbHandler: DBHandlerInterface
    
    init(apiClient: APIClientInterface = APIClient(), dbHandler: DBHandlerInterface = CoreDataStack.shared) {
        self.apiClient = apiClient
        self.dbHandler = dbHandler
    }
    
    func getMovieList(isReachable: Bool, keyword: String, page: Int) -> AnyPublisher<MovieResponseModel, AppError> {
        if isReachable {
            return getRemoteMovieList(keyword: keyword, page: page)
                .handleEvents(receiveOutput: { [weak self] response in
                    self?.dbHandler.saveMovies(response.results ?? [], keyword: keyword, page: page)
                })
                .eraseToAnyPublisher()
        }
        return dbHandler.getMovies(keyword: keyword, page: page)
            .map { MovieResponseModel(results: $0, page: page, totalPages: page + 1) }
            .eraseToAnyPublisher()
    }
    
    func getRemoteMovieList(keyword: String, page: Int) -> AnyPublisher<MovieResponseModel, AppError> {
        if keyword.isEmpty {
            return apiClient.getMovieList(page: page)
        }
        return apiClient.searchMovies(keyword: keyword, page: page)
    }
    
    func getMovieDetail(isReachable: Bool, movieId: Int) -> AnyPublisher<MovieModel, AppError> {
        if isReachable {
            return apiClient.getMovieDetail(movieId: movieId)
        }
        return dbHandler.getMovieDetail(movieId: movieId)
    }
}
