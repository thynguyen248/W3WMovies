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
    private let searchMoviesUseCase: SearchMoviesUseCaseInterface
    
    private var sections: [MovieListSection] = []
    private var currentPage = 0
    private var currentSearchText = ""
    
    init(movieListUseCase: MovieListUseCaseInterface = MovieListUseCase(),
         searchMoviesUseCase: SearchMoviesUseCaseInterface = SearchMoviesUseCase()) {
        self.movieListUseCase = movieListUseCase
        self.searchMoviesUseCase = searchMoviesUseCase
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
                if isReachable {
                    if self.currentPage == 0 || searchText != self.currentSearchText {
                        output.isLoading = true
                        self.reset()
                        self.currentSearchText = searchText
                    }
                    let targetPage = self.currentPage + 1
                    
                    // Search text is empty, perform loading trending movies
                    if searchText.isEmpty {
                        return self.movieListUseCase.getMovieList(page: targetPage)
                    }
                    // Perform searching
                    return self.searchMoviesUseCase.searchMovies(keyword: searchText, page: targetPage)
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
        handleMovieResponse(nil, sectionType: .main, reset: true)
    }
    
    private func handleMovieResponse(_ response: MovieResponseModel?, sectionType: MovieListSectionType, reset: Bool = false) {
        guard let idx = sections.firstIndex(where: { $0.sectionType == sectionType }) else {
            return
        }
        let items = response?.results?.map {
            MovieListCellItem(with: $0, page: response?.page ?? 0)
        }
        var section = sections[idx]
        if reset {
            section.items.removeAll()
        } else {
            section.items += (items ?? [])
        }
        section.hasMoreData = (response?.page ?? 0) < (response?.totalPages ?? 0)
        sections[idx] = section
        currentPage = response?.page ?? 0
    }
}
