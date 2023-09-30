//
//  SearchMoviesUseCase.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/29/23.
//

import Combine

protocol SearchMoviesUseCaseInterface {
    func searchMovies(keyword: String, page: Int) -> AnyPublisher<MovieResponseModel, AppError>
}

final class SearchMoviesUseCase: SearchMoviesUseCaseInterface {
    private let repository: MovieReposistoryInterface
    
    init(repository: MovieReposistoryInterface = MovieReposistory()) {
        self.repository = repository
    }
    
    func searchMovies(keyword: String, page: Int) -> AnyPublisher<MovieResponseModel, AppError> {
        repository.searchMovies(keyword: keyword, page: page)
    }
}
