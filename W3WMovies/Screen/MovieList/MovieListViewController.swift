//
//  MovieListViewController.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import UIKit
import Combine
import Reachability

final class MovieListViewController: UIViewController {
    typealias Snapshot = NSDiffableDataSourceSnapshot<MovieListSection, MovieListCellItem>
    typealias DataSource = UITableViewDiffableDataSource<MovieListSection, MovieListCellItem>
    
    private let loadMore = PassthroughSubject<Void, Never>()
    private let searchText = CurrentValueSubject<String, Never>("")
    
    private lazy var dataSource = makeDataSource()
    private var cancellables: Set<AnyCancellable> = []
    
    private let reachability = try! Reachability()
    
    var viewModel: MovieListViewModel
    
    // MARK: - UI properties
    private lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.searchBarStyle = UISearchBar.Style.prominent
        view.placeholder = " Search..."
        view.sizeToFit()
        view.isTranslucent = false
        view.backgroundImage = UIImage()
        view.delegate = self
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorColor = .gray
        tableView.keyboardDismissMode = .onDrag
        tableView.register(MovieListTableViewCell.self, forCellReuseIdentifier: MovieListTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        return view
    }()
    
    // MARK: - Initialization
    init(viewModel: MovieListViewModel = MovieListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    // MARK: - UI setup
    private func setupUI() {
        navigationController?.configDefaultBarStyle()
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(indicator)
        searchBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        indicator.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
        })
        
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
    
    private func makeDataSource() -> DataSource {
        let dataSource = UITableViewDiffableDataSource<MovieListSection, MovieListCellItem>(tableView: tableView) { (tableView, indexPath, cellItem) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieListTableViewCell.reuseIdentifier, for: indexPath) as? MovieListTableViewCell else {
                fatalError("Can not dequeue cell")
            }
            cell.config(with: cellItem)
            return cell
        }
        return dataSource
    }
    
    private func loadData() {
        loadMore.send(())
    }
}

// MARK: - Bindable
extension MovieListViewController: Bindable {
    func bindViewModel() {
        let input = MovieListViewModel.Input(isReachable: reachability.isReachable, searchText: searchText, loadMore: loadMore)
        let output = viewModel.transform(input: input)
        
        output.$isLoading
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [indicator, tableView] isLoading in
                if isLoading {
                    indicator.startAnimating()
                    tableView.setContentOffset(.zero, animated: false)
                } else {
                    indicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        output.$sections
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [dataSource] sections in
                var snapshot = Snapshot()
                snapshot.appendSections(sections)
                sections.forEach { section in
                    snapshot.appendItems(section.items, toSection: section)
                }
                dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        output.$error
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.showAlerWithMessage(error?.errorDescription ?? "")
            }
            .store(in: &cancellables)
    }
}

//MARK: - UISearchBarDelegate
extension MovieListViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText.send(searchText)
    }
}

//MARK: - UITableViewDelegate
extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        let movieDetailViewController = MovieDetailViewController(viewModel: MovieDetailViewModel(movieId: item.movieId))
        navigationController?.pushViewController(movieDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        guard section.hasMoreData, indexPath.row == section.items.count - 1 else {
            return
        }
        loadMore.send(())
    }
}
