//
//  IconSize.swift
//  iConFinder
//

struct IconSize: Equatable {
    let width: Int
    let height: Int
    
    static func ==(_ lhs: IconSize, _ rhs: IconSize) -> Bool {
        return lhs.height == rhs.height && lhs.width == rhs.width
    }
}
