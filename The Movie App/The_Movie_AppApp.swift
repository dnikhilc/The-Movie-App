//
//  The_Movie_AppApp.swift
//  The Movie App
//
//  Created by Nikhil Doppalapudi on 3/12/24.
//

import SwiftUI
import CoreData

@main
struct The_Movie_AppApp: App {
    
    let coreDataStack = CoreDataStack.shared
//    var movieVM = MovieListViewModel(networkService: NetworkHelper(), context: coreDataStack.container.viewContext)
    
    var body: some Scene {
        let networkService = NetworkHelper()
        let imageService = ImageFetchingService(networkService: networkService)
        let movieVM = MovieListViewModel(networkService: networkService, context: coreDataStack.container.viewContext, imageFetchingService: imageService)
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataStack.container.viewContext)
                .environmentObject( movieVM )
        }
    }
}
