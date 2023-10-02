//
//  CoreDataStack+movieDetail.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 10/1/23.
//

import CoreData
import Combine

extension CoreDataStack {
    func getMovieDetail(movieId: Int) -> AnyPublisher<MovieModel, AppError> {
        let predicate = NSPredicate(format: "movieId = %@", "\(movieId)")
        return fetch(objectType: MovieMO.self, predicate: predicate)
            .compactMap { $0.first?.movieModel }
            .eraseToAnyPublisher()
    }
}
