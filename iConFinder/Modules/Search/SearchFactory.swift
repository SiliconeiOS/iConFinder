//
//  SearchFactory.swift
//  iConFinder
//
//  Created by Иван Дроботов on 8/4/25.
//

import UIKit

enum SearchFactory {
    static func createModule(diContainer: DIContainer) -> UIViewController {
        let view = SearchViewController()
        let router = SearchRouter(viewController: view)
        let presenter = SearchPresenter(
            view: view,
            router: router,
            searchService: diContainer.searchService,
            imageService: diContainer.imageService,
            photoLibraryService: diContainer.photoLibraryService
        )

        view.presenter = presenter
        
        return view
    }
}
