//
//  PhotoLibraryService.swift
//  iConFinder

import UIKit
import Photos

enum PhotoLibraryError: Error, LocalizedError {
    case noPermission
    case saveFailed(Error?)
    
    var errorDescription: String? {
        switch self {
        case .noPermission:
            return "Permission to access the photo library was not granted. Please enable it in Settings."
        case .saveFailed(let underlyingError):
            return "Failed to save the image. \(underlyingError?.localizedDescription ?? "")"
        }
    }
}

protocol PhotoLibraryServiceProtocol {
    func saveImage(_ image: UIImage, completion: @escaping (Result<Void, PhotoLibraryError>) -> Void)
}

final class PhotoLibraryService: PhotoLibraryServiceProtocol {
    
    //MARK: - PhotoLibraryServiceProtocol Implementation
    
    func saveImage(_ image: UIImage, completion: @escaping (Result<Void, PhotoLibraryError>) -> Void) {
        requestAuthorization { [weak self] authorized in
            guard let self = self else { return }
            
            guard authorized else {
                completion(.failure(.noPermission))
                return
            }
            
            self.performSave(image, completion: completion)
        }
    }
    
    //MARK: - Private Section
    
    private func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                completion(newStatus == .authorized || newStatus == .limited)
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    private func performSave(_ image: UIImage, completion: @escaping (Result<Void, PhotoLibraryError>) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            if success {
                completion(.success(()))
            } else {
                completion(.failure(.saveFailed(error)))
            }
        }
    }
}
