//
//  SearchService.swift
//  iConFinder
//

protocol SearchServiceProtocol {
    func search(query: String, completion: @escaping (Result<[Icon], Error>) -> Void)
    func loadNextPage(completion: @escaping (Result<[Icon], Error>) -> Void)
    func reset()
}

final class SearchService: SearchServiceProtocol {
    
    //MARK: - Dependencies
    
    private let iconsService: IconsServiceProtocol
    private let iconsMapper: IconMapperProtocol
    private let debouncer: DebouncerProtocol
    
    //MARK: - State
    
    private var currentQuery: String?
    private var currentTask: Cancellable?
    private var totalCount = 0
    private let iconsPerPage = 30
    private var loadedIconsCount = 0
    private var isFirstFetch: Bool { totalCount == 0 }
    private var hasNextPage: Bool { isFirstFetch || loadedIconsCount < totalCount }
    
    
    //MARK: - Init
    
    init(
        iconsService: IconsServiceProtocol,
        iconsMapper: IconMapperProtocol,
        debouncer: DebouncerProtocol = Debouncer(delay: .milliseconds(500))
    ) {
        self.iconsService = iconsService
        self.iconsMapper = iconsMapper
        self.debouncer = debouncer
    }
    
    //MARK: - SearchServiceProtocol Implementation
    
    func search(query: String, completion: @escaping (Result<[Icon], Error>) -> Void) {
        reset()
        currentQuery = query
        debouncer.debounce { [weak self] in
            self?.fetchIcons(completion: completion)
        }
    }
    
    func loadNextPage(completion: @escaping (Result<[Icon], Error>) -> Void) {
        guard currentTask == nil, hasNextPage else {
            completion(.success([]))
            return
        }
        
        fetchIcons(completion: completion)
    }
    
    func reset() {
        currentTask?.cancel()
        currentTask = nil
        currentQuery = nil
        totalCount = 0
        loadedIconsCount = 0
        debouncer.cancel()
    }
    
    //MARK: - Private Section
    
    private func fetchIcons(completion: @escaping (Result<[Icon], Error>) -> Void) {
        
        guard let query = currentQuery else { return }
        
        let offset = loadedIconsCount
        
        currentTask = iconsService.fetchIcons(query: query, count: iconsPerPage, offset: offset) { [weak self] result in
            guard let self else { return }
            
            currentTask = nil
            
            switch result {
            case .success(let responseDTO):
                let newIcons = iconsMapper.map(responseDTO: responseDTO)
                if isFirstFetch {
                    totalCount = responseDTO.totalCount
                }
                loadedIconsCount += newIcons.count
                completion(.success(newIcons))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
