//
//  DBHandler.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/30/23.
//

import Combine
import Foundation
import CoreData

protocol DBHandlerInterface {
    func getMovies(keyword: String, page: Int) -> AnyPublisher<[MovieModel], AppError>
    
    @discardableResult
    func saveMovies(_ movies: [MovieModel], keyword: String, page: Int) -> AnyPublisher<[MovieModel], AppError>
    
    func getMovieDetail(movieId: Int) -> AnyPublisher<MovieModel, AppError>
}
