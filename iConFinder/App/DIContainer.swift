//
//  DIContainer.swift
//  iConFinder
//
//  Created by Иван Дроботов on 7/31/25.
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
    
    //MARK: - Network Service
    
    lazy var networkClient: NetworkClientProtocol = {
        NetworkClient(session: urlSession)
    }()
    
    lazy var imageLoader: ImageLoaderProtocol = {
        ImageLoader(networkClient: networkClient)
    }()
    
    lazy var iconsService: IconsServiceProtocol = {
        IconsService(
            networkClient: networkClient,
            dataParser: dataParser,
            iconMapper: iconMapper
        )
    }()
}
