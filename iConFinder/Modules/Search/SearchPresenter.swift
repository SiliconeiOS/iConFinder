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
    private let iconsService: IconsServiceProtocol
    private let imageService: ImageServiceProtocol
    private let photoLibraryService: PhotoLibraryServiceProtocol
    private let iconMapper: IconMapperProtocol

    // MARK: - State
    
    private var icons: [Icon] = []
    private var currentQuery: String?
    private var totalCount: Int = 0
    private var isLoading = false
    private var currentPageOffset: Int { icons.count }
    private let iconsPerPage = 30
    
    // MARK: - Init
    
    init(view: SearchViewProtocol,
         router: SearchRouterProtocol,
         iconsService: IconsServiceProtocol,
         imageService: ImageServiceProtocol,
         photoLibraryService: PhotoLibraryServiceProtocol,
         iconMapper: IconMapperProtocol) {
        self.view = view
        self.router = router
        self.iconsService = iconsService
        self.imageService = imageService
        self.photoLibraryService = photoLibraryService
        self.iconMapper = iconMapper
    }
    
    // MARK: - Private Methods
    
    private func performSearch(isNewSearch: Bool) {
        guard let query = currentQuery, !isLoading else { return }
        
        isLoading = true
        if isNewSearch {
            view?.display(state: .loading)
        }
        
        iconsService.fetchIcons(query: query, count: iconsPerPage, offset: currentPageOffset) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            DispatchQueue.main.async {
                switch result {
                case .success(let responseDTO):
                    self.handleSuccessResponse(responseDTO, isNewSearch: isNewSearch, query: query)
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
    private func handleSuccessResponse(_ response: NetworkDTO.IconsSearchResponse, isNewSearch: Bool, query: String) {
        let newIcons = iconMapper.map(responseDTO: response)
        
        if isNewSearch {
            self.totalCount = response.totalCount
            self.icons = newIcons
        } else {
            self.icons.append(contentsOf: newIcons)
        }
        
        let viewModels = self.icons.map { IconViewModel(icon: $0) }
        
        if self.icons.isEmpty {
            view?.display(state: .noResults(query: query))
        } else {
            view?.display(state: .content)
            if isNewSearch {
                view?.display(viewModels: viewModels)
            } else {
                view?.displayMore(viewModels: viewModels)
            }
        }
    }
    
    private func handleError(_ error: IconsServiceError) {
        // Показываем ошибку только если это был первый запрос,
        // чтобы не прерывать "бесконечный скролл"
        if currentPageOffset == 0 {
            view?.display(state: .error(message: error.localizedDescription))
        } else {
            router.showError(message: "Failed to load more icons. Please try again later.")
        }
    }
}

// MARK: - SearchPresenterProtocol

extension SearchPresenter: SearchPresenterProtocol {
    func viewDidLoad() {
        view?.display(state: .initial)
    }

    func search(for query: String) {
        currentQuery = query
        icons = []
        totalCount = 0
        performSearch(isNewSearch: true)
    }
    
    func didCancelSearch() {
        currentQuery = nil
        icons = []
        totalCount = 0
        view?.display(viewModels: [])
        view?.display(state: .initial)
    }

    func loadNextPage() {
        guard let query = currentQuery, !query.isEmpty, !isLoading, icons.count < totalCount else {
            return
        }
        performSearch(isNewSearch: false)
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
    
    private func saveImageToLibrary(_ image: UIImage) {
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
