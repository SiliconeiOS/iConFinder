//
//  DownlodIconRequestBuilderMock.swift
//  iConFinderTests
//

import Foundation
@testable import iConFinder

final class DownloaIconRequestBuilderMock: DownloadIconRequestBuilder {
    
    func downloadIcon(from url: URL) -> URLRequest {
        return URLRequest(url: url)
    }
}
