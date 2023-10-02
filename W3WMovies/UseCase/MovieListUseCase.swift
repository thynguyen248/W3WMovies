//
//  MovieListUseCase.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Combine

protocol MovieListUseCaseInterface {
    func getMovieList(isReachable: Bool, keyword: String, page: Int) -> AnyPublisher<MovieResponseModel, AppError>
}

final class MovieListUseCase: MovieListUseCaseInterface {
    private let repository: MovieReposistoryInterface
    
    init(repository: MovieReposistoryInterface = MovieReposistory()) {
        self.repository = repository
    }
    
    func getMovieList(isReachable: Bool, keyword: String, page: Int) -> AnyPublisher<MovieResponseModel, AppError> {
        repository.getMovieList(isReachable: isReachable, keyword: keyword, page: page)
    }
}
