//
//  ViewController.swift
//  iConFinder
//

import UIKit

protocol SearchViewProtocol: AnyObject {
    func display(viewModels: [IconViewModel])
    func displayMore(newViewModels: [IconViewModel])
    func display(state: SearchView.State)
}

final class SearchViewController: UIViewController {

    // MARK: - Dependencies
    
    var presenter: SearchPresenterProtocol!
    
    // MARK: - UI
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for icons..."
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        tableView.register(IconCell.self, forCellReuseIdentifier: IconCell.reuseIdentifier)
        tableView.rowHeight = 120
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private lazy var stateView = SearchView.StateView()
    
    // MARK: - State
    
    private var viewModels: [IconViewModel] = []

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        title = "iConFinder"
        view.backgroundColor = .systemBackground
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        view.addSubview(tableView)
        view.addSubview(stateView)
        
        stateView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            stateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
}

// MARK: - SearchViewProtocol

extension SearchViewController: SearchViewProtocol {
    func display(viewModels: [IconViewModel]) {
        self.viewModels = viewModels
        tableView.reloadData()
        if !viewModels.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    func displayMore(newViewModels: [IconViewModel]) {
        let currentCount = self.viewModels.count
        let newItemsCount = newViewModels.count
        let newTotalCount = currentCount + newItemsCount
        let indexPaths = (currentCount..<newTotalCount).map { IndexPath(row: $0, section: 0) }
        
        
        self.viewModels.append(contentsOf: newViewModels)
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func display(state: SearchView.State) {
        stateView.configure(with: state)
        tableView.isHidden = !state.isTableViewVisible
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension SearchViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IconCell.reuseIdentifier, for: indexPath) as? IconCell else {
            return UITableViewCell()
        }
        
        let viewModel = viewModels[indexPath.row]
        
        cell.configure(with: viewModel) { [weak self] completionHandler in
            return self?.presenter.fetchImage(for: viewModel.previewURL, completion: completionHandler)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectIcon(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { $0.row >= viewModels.count - 1 }) {
            presenter.loadNextPage()
        }
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        presenter.search(for: query)
        searchController.dismiss(animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.didCancelSearch()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            presenter.didCancelSearch()
        } else {
            presenter.search(for: trimmed)
        }
    }
}
