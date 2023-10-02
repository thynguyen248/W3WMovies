//
//  MovieListViewModel.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Foundation
import Combine

final class MovieListViewModel: ViewModelType {
    struct Input {
        let isReachable: AnyPublisher<Bool, Never>
        let searchText: CurrentValueSubject<String, Never>
        let loadMore: PassthroughSubject<Void, Never>
    }

    final class Output {
        @Published var isLoading = false
        @Published var sections: [MovieListSection] = []
        @Published var error: AppError?
    }
    
    private let movieListUseCase: MovieListUseCaseInterface
    
    private var sections: [MovieListSection] = []
    private var currentPage = 0
    private var currentSearchText = ""
    
    init(movieListUseCase: MovieListUseCaseInterface = MovieListUseCase()) {
        self.movieListUseCase = movieListUseCase
        sections.append(MovieListSection(sectionType: .main))
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        let searchTextPublisher = input.searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
        
        let moviesPublisher = Publishers.CombineLatest3(input.isReachable.removeDuplicates(),
                                                        searchTextPublisher,
                                                        input.loadMore)
            .flatMap { [weak self] (isReachable, searchText, _) -> AnyPublisher<MovieResponseModel, AppError> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                if self.currentPage == 0 || searchText != self.currentSearchText {
                    output.isLoading = true
                    self.reset()
                    self.currentSearchText = searchText
                }
                let targetPage = self.currentPage + 1
                return self.movieListUseCase.getMovieList(isReachable: isReachable, keyword: searchText, page: targetPage)
            }
            .asResult()
            .handleEvents(receiveOutput: { _ in
                output.isLoading = false
            })
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .share()
        
        moviesPublisher
            .map { [weak self] result -> [MovieListSection] in
                guard case .success(let response) = result else { return [] }
                self?.handleMovieResponse(response, sectionType: .main)
                return self?.sections ?? []
            }
            .assign(to: &output.$sections)
        
        moviesPublisher
            .compactMap { result -> AppError? in
                guard case .failure(let error) = result else { return nil }
                return error
            }
            .assign(to: &output.$error)
        
        return output
    }
    
    private func reset() {
        currentPage = 0
        for idx in sections.indices {
            sections[idx].items.removeAll()
        }
    }
    
    private func handleMovieResponse(_ response: MovieResponseModel?, sectionType: MovieListSectionType) {
        guard let idx = sections.firstIndex(where: { $0.sectionType == sectionType }),
              let models = response?.results, !models.isEmpty else {
            return
        }
        let items = models
            .map { MovieListCellItem(with: $0, page: response?.page ?? 0) }
            .sorted(by: >)
        var section = sections[idx]
        section.items += items
        section.hasMoreData = (response?.page ?? 0) < (response?.totalPages ?? 0)
        sections[idx] = section
        currentPage = response?.page ?? 0
    }
}
