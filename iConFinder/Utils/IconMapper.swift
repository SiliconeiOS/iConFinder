//
//  IconMapper.swift
//  iConFinder
//

import Foundation

protocol IconMapperProtocol {
    func map(responseDTO: NetworkDTO.IconsSearchResponse) -> [Icon]
}

final class IconMapper: IconMapperProtocol {
    
    //MARK: - IconMapperProtocol Implementation
    
    func map(responseDTO: NetworkDTO.IconsSearchResponse) -> [Icon] {
        var icons = [Icon]()
        
        for iconDTO in responseDTO.icons {
            do {
                let icon = try Icon(from: iconDTO)
                icons.append(icon)
            } catch {
                Logger.error("Mapping failed for icon ID \(iconDTO.iconId). Reason: \(error.localizedDescription)")
            }
        }
        
        return icons
    }
}
