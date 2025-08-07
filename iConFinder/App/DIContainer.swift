//
//  DIContainer.swift
//  iConFinder
//

import Foundation

final class DIContainer {
    
    //MARK: - Core Dependencies
    
    lazy var urlCache: URLCache = {
        let memoryCapacity = 50 * 1024 * 1024 // 50 MB
        let diskCapacity = 200 * 1024 * 1024  // 200 MB
        let diskPath = "iConFinder_cache"
        return URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: diskPath)
    }()
    
    lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = urlCache
        return URLSession(configuration: configuration)
    }()
    
    lazy var dataParser: DataParserProtocol = {
        DataParser()
    }()
    
    lazy var iconMapper: IconMapperProtocol = {
        IconMapper()
    }()
    
    //MARK: - Internal Services
    
    lazy var networkClient: NetworkClientProtocol = {
        NetworkClient(session: urlSession)
    }()

    lazy var imageService: ImageServiceProtocol = {
        ImageService(networkClient: networkClient)
    }()

    lazy var iconsService: IconsServiceProtocol = {
        IconsService(
            networkClient: networkClient,
            dataParser: dataParser
        )
    }()

    lazy var photoLibraryService: PhotoLibraryServiceProtocol = {
        PhotoLibraryService()
    }()
    
    //MARK: - High-level Services
    
    lazy var searchService: SearchServiceProtocol = {
        SearchService(
            iconsService: iconsService,
            iconsMapper: iconMapper
        )
    }()
}
