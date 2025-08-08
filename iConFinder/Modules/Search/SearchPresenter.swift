//
//  SearchPresenter.swift
//  iConFinder
//

import Foundation
import UIKit

protocol SearchPresenterProtocol {
    func viewDidLoad()
    func search(for query: String)
    func didCancelSearch()
    func loadNextPage()
    func fetchImage(for url: URL, completion: @escaping (Result<UIImage, ImageServiceError>) -> Void) -> Cancellable?
    func didSelectIcon(at index: Int)
}

final class SearchPresenter {

    // MARK: - Dependencies
    
    private weak var view: SearchViewProtocol?
    private let router: SearchRouterProtocol
    private let searchService: SearchServiceProtocol
    private let imageService: ImageServiceProtocol
    private let photoLibraryService: PhotoLibraryServiceProtocol

    // MARK: - State
    
    private var icons: [Icon] = []

    // MARK: - Init
    
    init(
        view: SearchViewProtocol,
        router: SearchRouterProtocol,
        searchService: SearchServiceProtocol,
        imageService: ImageServiceProtocol,
        photoLibraryService: PhotoLibraryServiceProtocol
    ) {
        self.view = view
        self.router = router
        self.searchService = searchService
        self.imageService = imageService
        self.photoLibraryService = photoLibraryService
    }
}

// MARK: - SearchPresenterProtocol

extension SearchPresenter: SearchPresenterProtocol {
    func viewDidLoad() {
        view?.display(state: .initial)
    }

    func search(for query: String) {
        view?.display(state: .loading)
        searchService.search(query: query) { [weak self] result in
            self?.handleSearchResult(result: result, forQuery: query, isNewSearch: true)
        }
    }
    
    func didCancelSearch() {
        searchService.reset()
        icons = []
        view?.display(viewModels: [])
        view?.display(state: .initial)
    }

    func loadNextPage() {
        searchService.loadNextPage { [weak self] result in
            self?.handleSearchResult(result: result, forQuery: "", isNewSearch: false)
        }
    }

    @discardableResult
    func fetchImage(for url: URL, completion: @escaping (Result<UIImage, ImageServiceError>) -> Void) -> Cancellable? {
        return imageService.fetchImage(from: url, completion: completion)
    }
    
    func didSelectIcon(at index: Int) {
        guard icons.indices.contains(index) else { return }
        let icon = icons[index]
        
        router.showLoading(true)
        imageService.fetchImage(from: icon.downloadURL) { [weak self] result in
            guard let self else { return }
            router.showLoading(false)
            
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.saveImageToLibrary(image)
                case .failure(let error):
                    self.router.showError(message: error.localizedDescription)
                }
            }
        }
    }
}

//MARK: - Private Section

private extension SearchPresenter {
    func handleSearchResult(result: Result<[Icon], Error>, forQuery query: String, isNewSearch: Bool) {
            switch result {
            case .success(let newIcons):
                if isNewSearch {
                    self.icons = newIcons
                } else {
                    guard !newIcons.isEmpty else { return }
                    self.icons.append(contentsOf: newIcons)
                }
                
                if self.icons.isEmpty && isNewSearch {
                    self.view?.display(state: .noResults(query: query))
                } else {
                    self.view?.display(state: .content)
                    if isNewSearch {
                        let viewModels = self.icons.map { IconViewModel(icon: $0) }
                        self.view?.display(viewModels: viewModels)
                    } else {
                        let newViewModels = newIcons.map { IconViewModel(icon: $0) }
                        self.view?.displayMore(newViewModels: newViewModels)
                    }
                }
                
            case .failure(let error):
                if isNewSearch {
                    view?.display(state: .error(message: error.localizedDescription))
                } else {
                    router.showError(message: "Failed to load more icons: \(error.localizedDescription)")
                }
            }
        }
    
    func saveImageToLibrary(_ image: UIImage) {
        photoLibraryService.saveImage(image) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.router.showMessage(title: "Success", message: "Icon saved to your Photo Library.")
                case .failure(let error):
                    self?.router.showError(message: error.localizedDescription)
                }
            }
        }
    }
}
