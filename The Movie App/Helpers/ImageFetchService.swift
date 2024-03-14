//
//  ImageFetchService.swift
//  The Movie App
//
//  Created by Nikhil Doppalapudi on 3/14/24.
//

import Foundation
import SwiftUI

protocol ImageFetchingServiceProtocol{
    func fetchImages<T: ImageRepresentable>(for items: [T]) async -> [Int: Image]
}

class ImageFetchingService: ImageFetchingServiceProtocol{
    
    private let networkService: NetworkServiceProtocl
    private let configManager: ConfigurationManager
    
    init(networkService: NetworkServiceProtocl, configManager: ConfigurationManager = .shared) {
        self.networkService = networkService
        self.configManager = configManager
    }
    
    @MainActor
    func fetchImages<T: ImageRepresentable>(for items: [T]) async -> [Int: Image] {
        var images: [Int: Image] = [:]
        
        for item in items {
            guard let imagePath = item.imagePath, !imagePath.isEmpty else { continue }
            let fullImagePath = "\(configManager.imageBaseURL)\(imagePath)"
            
            do {
                let imageData = try await networkService.fetchImage(url: fullImagePath)
                if let uiImage = UIImage(data: imageData) {
                    images[item.id] = Image(uiImage: uiImage)
                }
            } catch {
                print("Failed to load image for item \(item.id): \(error.localizedDescription)")
            }
        }
        
        return images
    }
    
    
}
