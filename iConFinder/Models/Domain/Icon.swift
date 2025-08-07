//
//  Icon.swift
//  iConFinder
//

import Foundation

enum MappingError: Error, LocalizedError {
    case noRasterSizes
    case noFormatsInRasterSize
    case invalidPreviewURL(String)
    case invalidDownloadURL(String)
    
    var errorDescription: String? {
        switch self {
        case .noRasterSizes:
            return "Server response for an icon is missing 'raster_sizes'."
        case .noFormatsInRasterSize:
            return "A raster size is missing 'formats' information."
        case .invalidPreviewURL(let url):
            return "The provided preview_url is not a valid URL: \(url)"
        case .invalidDownloadURL(let url):
            return "The provided download_url is not a valid URL: \(url)"
        }
    }
}

struct Icon {
    let id: Int
    let tags: [String]
    let largestSize: IconSize
    let previewURL: URL
    let downloadURL: URL
}

//MARK: - Maping from NetworkDTO

extension Icon {
    init(from dto: NetworkDTO.Icon) throws {
        
        guard let largestRasterSize = dto.rasterSizes.sorted(by: { $0.size >  $1.size }).first else {
            throw MappingError.noRasterSizes
        }
        
        guard let formatDTO = largestRasterSize.formats.first else {
            throw MappingError.noFormatsInRasterSize
        }
        
        guard let previewURL = URL(string: formatDTO.previewURL) else {
            throw MappingError.invalidPreviewURL(formatDTO.previewURL)
        }
        
        guard let downloadURL = URL(string: formatDTO.downloadURL) else {
            throw MappingError.invalidDownloadURL(formatDTO.downloadURL)
        }
        
        self.id = dto.iconId
        self.tags = dto.tags
        self.largestSize = IconSize(width: largestRasterSize.sizeWidth, height: largestRasterSize.sizeHeight)
        self.previewURL = previewURL
        self.downloadURL = downloadURL
    }
}
