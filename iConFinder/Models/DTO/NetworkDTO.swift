//
//  IconsDTO.swift
//  iConFinder
//

enum NetworkDTO {
    struct IconsSearchResponse: Codable {
        let totalCount: Int
        let icons: [Icon]
        
        enum CodingKeys: String, CodingKey {
            case totalCount = "total_count"
            case icons
        }
    }
    
    struct Icon: Codable {
        let iconId: Int
        let tags: [String]
        let rasterSizes: [RasterSize]
        
        enum CodingKeys: String, CodingKey {
            case iconId = "icon_id"
            case tags
            case rasterSizes = "raster_sizes"
        }
    }
    
    struct RasterSize: Codable {
        let sizeHeight: Int
        let sizeWidth: Int
        let size: Int
        let formats: [Format]
        
        enum CodingKeys: String, CodingKey {
            case sizeHeight = "size_height"
            case sizeWidth = "size_width"
            case size
            case formats
        }
    }
    
    struct Format: Codable {
        let previewURL: String
        let downloadURL: String
        
        enum CodingKeys: String, CodingKey {
            case previewURL = "preview_url"
            case downloadURL = "download_url"
        }
    }
}
