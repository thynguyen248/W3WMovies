//
//  MovieDetailViewController.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import UIKit
import Combine
import Reachability

final class MovieDetailViewController: UIViewController {
    typealias Snapshot = NSDiffableDataSourceSnapshot<MovieDetailSection, MovieDetailCellItem>
    typealias DataSource = UITableViewDiffableDataSource<MovieDetailSection, MovieDetailCellItem>
    
    private let loadTrigger = PassthroughSubject<Void, Never>()
    
    private lazy var dataSource = makeDataSource()
    private var cancellables: Set<AnyCancellable> = []
    
    private let reachability = try! Reachability()
    
    var viewModel: MovieDetailViewModel
    
    // MARK: - UI properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(MovieMediaTableViewCell.self, forCellReuseIdentifier: MovieMediaTableViewCell.reuseIdentifier)
        tableView.register(MovieOverviewTableViewCell.self, forCellReuseIdentifier: MovieOverviewTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        return view
    }()
    
    // MARK: - Initialization
    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
//        navigationController?.isNavigationBarHidden = true
        view.addSubview(tableView)
        view.addSubview(indicator)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        indicator.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
        })
        tableView.dataSource = dataSource
    }
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(tableView: tableView) { (tableView, indexPath, cellItem) -> UITableViewCell? in
            switch cellItem {
            case .media(let item):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieMediaTableViewCell.reuseIdentifier, for: indexPath) as? MovieMediaTableViewCell else {
                    fatalError("Can not dequeue cell")
                }
                cell.config(with: item)
                return cell
            case .overview(let item):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieOverviewTableViewCell.reuseIdentifier, for: indexPath) as? MovieOverviewTableViewCell else {
                    fatalError("Can not dequeue cell")
                }
                cell.config(with: item)
                return cell
            }
        }
        return dataSource
    }
    
    private func loadData() {
        loadTrigger.send(())
    }
}

// MARK: - Bindable
extension MovieDetailViewController: Bindable {
    func bindViewModel() {
        let input = MovieDetailViewModel.Input(isReachable: reachability.isReachable, loadTrigger: loadTrigger)
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
