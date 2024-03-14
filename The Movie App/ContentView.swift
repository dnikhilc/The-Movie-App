//
//  ContentView.swift
//  The Movie App
//
//  Created by Nikhil Doppalapudi on 3/12/24.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var movieVM: MovieListViewModel
    private var showAlert: Bool {
        !movieVM.errorMessage.isEmpty
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView{
            VStack {
                ScrollView{
                    LazyVGrid(columns: columns, spacing: 20) {
                        // Loop through the images array
                        ForEach(movieVM.movieList) { movie in
                            NavigationLink {
                                MovieDetailView(movieId: movie.id)
                            } label: {
                                MovieCellView(movieDetails: movie)
                            }
                        }
                    }
                    .padding()
                }
                
                HStack {
                    Button("Previous Page") {
                        Task {
                            await movieVM.previousPage()
                        }
                    }
                    .disabled(movieVM.currentPage <= 1)
                    
                    Spacer()
                    
                    movieVM.networkAbsent ? Text("No Network, showing cache") : Text("Page \(movieVM.currentPage) of \(movieVM.totalPages)")
                    
                    Spacer()
                    
                    Button("Next Page") {
                        Task {
                            await movieVM.nextPage()
                        }
                    }
                    .disabled(movieVM.currentPage >= movieVM.totalPages)
                }
                .padding()
            }
        }
        .navigationTitle("Popular Movies")
        .task {
            await movieVM.getData()
        }
        .alert("OOPS..!", isPresented: .constant(showAlert)) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(movieVM.errorMessage)
        }
    }
}

#Preview {
    ContentView()
}
