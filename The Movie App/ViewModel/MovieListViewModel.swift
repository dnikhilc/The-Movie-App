//
//  MovieListViewModel.swift
//  The Movie App
//
//  Created by Nikhil Doppalapudi on 3/12/24.
//

import Foundation
import SwiftUI
import CoreData
import Network

class MovieListViewModel: ObservableObject{
    
    @Published var movieList : [Result] = []
    @Published var images: [Int: Image] = [:]
    @Published var isLoading : Bool = false
    @Published var errorMessage : String = ""
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
    @Published var networkAbsent : Bool = false
    private let networkMonitor = NWPathMonitor()
    private var context : NSManagedObjectContext
    private let queue = DispatchQueue.global(qos: .background)
    private let configManager: ConfigurationManager
    private let imageFetchingService: ImageFetchingServiceProtocol
    
    private let networkService: NetworkServiceProtocl
    
    init(networkService: NetworkServiceProtocl, 
         context: NSManagedObjectContext,
         configManager: ConfigurationManager = .shared,
         imageFetchingService: ImageFetchingService) {
        
        self.networkService = networkService
        self.context = context
        self.configManager = configManager
        self.imageFetchingService = imageFetchingService
        startNetworkMonitoring()
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            
            guard let viewModel = self else {
                return
            }
            
            if path.status == .satisfied{
                Task {
                    await viewModel.fetchAndCacheDataNew()
                }
            } else {
                Task {
                    await viewModel.loadDataFromCache()
                }
            }
        }
        networkMonitor.start(queue: queue)
    }
    
    @MainActor
    func getData() async{
        //        print("Going to call data")
        isLoading = true
        if networkMonitor.currentPath.status == .satisfied {
            await fetchAndCacheDataNew()
        } else {
            await loadDataFromCache()
        }
        isLoading = false
    }
    
    @MainActor
    private func fetchAndCacheDataNew() async{
        //        print("Coming to new network calls")
        let movieURL = "\(configManager.baseURL)popular?language=en-US&page=\(currentPage)"
        self.networkAbsent = false
        do {
            let movies : MovieModel = try await networkService.fetchData(url: movieURL)
            self.movieList = movies.results
            self.totalPages = movies.totalPages
            try cacheMovies(data: movieList)
//            await fetchImagesForMovies()  // Fetch images if necessary
            self.images = await imageFetchingService.fetchImages(for: movieList)
        } catch NetworkError.invalidURL{
            errorMessage = "Invalid URL"
        }
        catch NetworkError.badResponse(let statusCode){
            errorMessage = "Bad response: \(statusCode)"
        }
        catch NetworkError.decodingError(let decodingError){
            errorMessage = "Error while decoding \(decodingError)"
        }
        catch NetworkError.requestFailed(let requestError){
            errorMessage = "request error \(requestError)"
        } catch {
            errorMessage = "An unexpected error occured \(error)"
        }
    }
    
    @MainActor
    private func loadDataFromCache() async {
        self.networkAbsent = true
        if let cachedMovies = loadCachedMovies(), !cachedMovies.isEmpty {
            self.movieList = cachedMovies
        } else {
            self.errorMessage = "No internet connection and no cached data available."
        }
    }
    
//    
    @MainActor
    func nextPage() async {
        guard currentPage < totalPages else { return }
        currentPage += 1
        await getData()
    }
    
    @MainActor
    func previousPage() async {
        guard currentPage > 1 else { return }
        currentPage -= 1
        await getData()
    }
    
    
    private func cacheMovies(data: [Result]) throws{
        // Delete old cache
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CachedMovie")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? context.execute(deleteRequest)
        
        for movieData in data {
            let cachedMovie = NSEntityDescription.insertNewObject(forEntityName: "CachedMovie", into: context) as! CachedMovie
            cachedMovie.id = Int32(movieData.id)
            cachedMovie.title = movieData.title
            cachedMovie.posterPath = movieData.posterPath
            cachedMovie.adult = movieData.adult
            cachedMovie.backdropPath = movieData.backdropPath
            cachedMovie.genreIDS = movieData.genreIDS as NSObject
            cachedMovie.originalTitle = movieData.originalTitle
            cachedMovie.overview = movieData.overview
            cachedMovie.popularity = movieData.popularity
            cachedMovie.releaseDate = movieData.releaseDate
            cachedMovie.video = movieData.video
            cachedMovie.voteAverage = movieData.voteAverage
            cachedMovie.voteCount = Int32(movieData.voteCount)
            // Set other properties as needed
        }
        
        do {
            try context.save()
        } catch {
            //            print("Failed to save context: \(error)")
            throw DatabaseError.databaseSaveError(error)
        }
    }
    
    
    private func loadCachedMovies() -> [Result]? {
        let request: NSFetchRequest<CachedMovie> = CachedMovie.fetchRequest()
        if let cachedMovies = try? context.fetch(request) {
            //            return cachedMovies.map { Result(id: Int($0.id), title: $0.title, posterPath: $0.posterPath) }
            return cachedMovies.map { movie in
                Result(
                    adult: movie.adult,
                    backdropPath: movie.backdropPath ?? "default",
                    genreIDS: movie.genreIDS as! [Int],
                    id: Int(movie.id),
                    originalTitle: movie.originalTitle ?? "Default Title",
                    overview: movie.overview ?? "Default",
                    popularity: movie.popularity,
                    posterPath: movie.posterPath ?? "",
                    releaseDate: movie.releaseDate ?? "default",
                    title: movie.title ?? "default Title",
                    video: movie.video,
                    voteAverage: movie.voteAverage,
                    voteCount: Int(movie.voteCount))
            }
        }
        return nil
    }
}

enum DatabaseError : Error{
    case databaseSaveError(Error)
    case databaseFectchError(Error)
}
