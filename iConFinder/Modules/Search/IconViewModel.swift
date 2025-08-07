//
//  IconViewModel.swift
//  iConFinder
//
//  Created by Иван Дроботов on 8/7/25.
//

import Foundation

struct IconViewModel {
    let previewURL: URL
    let sizeText: String
    let tagsText: String
    
    init(icon: Icon) {
        self.previewURL = icon.previewURL
        self.sizeText = "Size: \(icon.largestSize.width)x\(icon.largestSize.height)"
        
        let tagsToDisplay = icon.tags.prefix(10)
        self.tagsText = "Tags: \(tagsToDisplay.joined(separator: ", "))"
    }
}
