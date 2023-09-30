//
//  Publisher+result.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Combine

extension Publisher {
    func asResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        self.map(Result.success)
            .catch { error in
                Just(.failure(error))
            }
            .eraseToAnyPublisher()
    }
}
