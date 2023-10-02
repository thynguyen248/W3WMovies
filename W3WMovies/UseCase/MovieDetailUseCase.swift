//
//  MovieDetailUseCase.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Combine

protocol MovieDetailUseCaseInterface {
    func getMovieDetail(isReachable: Bool, movieId: Int) -> AnyPublisher<MovieModel, AppError>
}

final class MovieDetailUseCase: MovieDetailUseCaseInterface {
    private let repository: MovieReposistoryInterface
    
    init(repository: MovieReposistoryInterface = MovieReposistory()) {
        self.repository = repository
    }
    
    func getMovieDetail(isReachable: Bool, movieId: Int) -> AnyPublisher<MovieModel, AppError> {
        repository.getMovieDetail(isReachable: isReachable, movieId: movieId)
    }
}
