//
//  MovieDetailViewModel.swift
//  The Movie App
//
//  Created by Nikhil Doppalapudi on 3/13/24.
//

import Foundation
import SwiftUI

class MovieDetailViewModel: ObservableObject{
    
    @Published var movieDetail : MovieDetailModel?
    @Published var errorMessage : String = ""
    @Published var castDetails : [Cast] = []
    @Published var images: [Int: Image] = [:]
    private let networkService: NetworkServiceProtocl
    private let configManager: ConfigurationManager
    private let imageFetchingService: ImageFetchingServiceProtocol
    
    init(networkService: NetworkServiceProtocl, configManager: ConfigurationManager = .shared, imageFetchingService: ImageFetchingService) {
        self.networkService = networkService
        self.configManager = configManager
        self.imageFetchingService = imageFetchingService
    }
    
    @MainActor
    func getData(movieId: Int) async{

        let movieURL = "\(configManager.baseURL)\(movieId)?language=en-US"
        let castURL = "\(configManager.baseURL)\(movieId)/credits?language=en-US"
        
        do{
            movieDetail = try await networkService.fetchData(url: movieURL)
            let movieCast : MovieCastModel = try await networkService.fetchData(url: castURL)
            castDetails = movieCast.cast
            self.images = await imageFetchingService.fetchImages(for: castDetails)
        } catch NetworkError.invalidURL{
            errorMessage = "Invalid URL"
        }
        catch NetworkError.badResponse(let statusCode){
            errorMessage = "Bad response: \(statusCode)"
//            print(errorMessage)
        }
        catch NetworkError.decodingError(let decodingError){
            errorMessage = "Error while decoding \(decodingError)"
//            print(errorMessage)
        }
        catch NetworkError.requestFailed(_){
            errorMessage = "Could you check the network reachability. Caching is only done for movies List."
//            print(errorMessage)
        } catch {
            errorMessage = "An unexpected error occured \(error)"
//            print(errorMessage)
        }
    }
    
    @MainActor
    private func fetchImagesForMovies() async {
        
        
        for cast in castDetails {
            let imagePath = cast.profilePath ?? ""
//            let fullImagePath = "https://image.tmdb.org/t/p/w500/\(imagePath)"
            let fullImagePath = "\(configManager.imageBaseURL)\(imagePath)"
//            print("Image Url is \(fullImagePath)")
            do {
                let imageData = try await networkService.fetchImage(url: fullImagePath)
                if let uiImage = UIImage(data: imageData) {
                    self.images[cast.id] = Image(uiImage: uiImage)
                }
            } catch {
                print("Failed to load image for cast \(cast.id): \(error.localizedDescription)")
            }
        }
    }
}
