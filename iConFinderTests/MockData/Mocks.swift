//
//  Mocks.swift
//  iConFinderTests
//

import Foundation
@testable import iConFinder

func makeMinimalValidDataPNG() -> Data {
    let base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
    return Data(base64Encoded: base64)!
}

func makeIconDTO(
    id: Int,
    tags: [String] = ["test"],
    size: Int = 128,
    previewURL: String = "https://example.com/image.png",
    downloadURL: String = "https://example.com/download.png"
) -> NetworkDTO.Icon {
    let format = NetworkDTO.Format(previewURL: previewURL, downloadURL: downloadURL)
    let rasterSize = NetworkDTO.RasterSize(sizeHeight: size, sizeWidth: size, size: size, formats: [format])
    return NetworkDTO.Icon(iconId: id, tags: tags, rasterSizes: [rasterSize])
}
