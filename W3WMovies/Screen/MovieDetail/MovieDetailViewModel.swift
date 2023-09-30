//
//  MovieDetailViewModel.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Foundation
import Combine

final class MovieDetailViewModel: ViewModelType {
    struct Input {
        let isReachable: AnyPublisher<Bool, Never>
        let loadTrigger: PassthroughSubject<Void, Never>
    }

    final class Output {
        @Published var isLoading = false
        @Published var sections: [MovieDetailSection] = []
        @Published var error: AppError?
    }
    
    private let movieDetailUseCase: MovieDetailUseCaseInterface
    private let movieId: Int
    
    private var sections: [MovieDetailSection] = []
    
    init(movieDetailUseCase: MovieDetailUseCaseInterface = MovieDetailUseCase(),
         movieId: Int) {
        self.movieDetailUseCase = movieDetailUseCase
        self.movieId = movieId
        sections.append(MovieDetailSection(sectionType: .main))
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        let movieDetailPublisher = Publishers.CombineLatest(input.isReachable.removeDuplicates(),
                                                            input.loadTrigger)
            .flatMap { [movieDetailUseCase, movieId] (isReachable, _) -> AnyPublisher<MovieModel, AppError> in
                if isReachable {
                    return movieDetailUseCase.getMovieDetail(movieId: movieId)
                }
                return Empty().eraseToAnyPublisher()
            }
            .asResult()
            .handleEvents(receiveOutput: { _ in
                output.isLoading = false
            })
            .receive(on: RunLoop.main)
            .share()
            .eraseToAnyPublisher()
        
        movieDetailPublisher
            .map { [weak self] result -> [MovieDetailSection] in
                guard case .success(let response) = result else { return [] }
                self?.handleMovieDetailResponse(response, sectionType: .main)
                return self?.sections ?? []
            }
            .assign(to: &output.$sections)
        
        movieDetailPublisher
            .compactMap { result -> AppError? in
                guard case .failure(let error) = result else { return nil }
                return error
            }
            .assign(to: &output.$error)
        
        return output
    }
    
    private func handleMovieDetailResponse(_ response: MovieModel?, sectionType: MovieDetailSectionType) {
        guard let response = response, let idx = sections.firstIndex(where: { $0.sectionType == sectionType }) else {
            return
        }
        let mediaItem = MovieDetailCellItem.media(item: MovieMediaCellItem(with: response))
        let overviewItem = MovieDetailCellItem.overview(item: MovieOverviewCellItem(with: response))
        var section = sections[idx]
        section.items = [mediaItem, overviewItem]
        sections[idx] = section
    }
}
