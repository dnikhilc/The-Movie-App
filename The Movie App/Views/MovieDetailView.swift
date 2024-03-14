//
//  MovieDetailView.swift
//  The Movie App
//
//  Created by Nikhil Doppalapudi on 3/13/24.
//

import SwiftUI

struct MovieDetailView: View {
    
    @EnvironmentObject var movieVM: MovieListViewModel
    @ObservedObject var movieDetailVM : MovieDetailViewModel
    var movieId : Int
    private var showAlert: Bool {
        !movieDetailVM.errorMessage.isEmpty
    }
    
    init(movieId: Int){
        let networkService = NetworkHelper()
        let imageService = ImageFetchingService(networkService: networkService)
        movieDetailVM = MovieDetailViewModel(networkService: networkService, imageFetchingService: imageService)
        self.movieId = movieId
    }
    
    var body: some View {
        
        VStack{
            if let image = movieVM.images[movieId]{
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, minHeight: 200, maxHeight: 300)
            }
            ZStack{
                RoundedRectangle(cornerRadius: 10.0)
                    .frame(height: 600)
                ScrollView {
                    if let movieDetail = movieDetailVM.movieDetail{
                        VStack(alignment: .leading, spacing: 10){
                            Spacer()
                            HStack{
                                Text(movieDetail.title)
                                    .font(.title)
                                    .bold()
                                Spacer()
                                Text(movieDetail.releaseDate)
                                    .font(.subheadline)
                            }.padding(.horizontal)
                            Text(movieDetail.overview)
                                .font(.caption)
                                .padding(.horizontal)
                            Text ("Cast :")
                                .font(.headline)
                            
                            ScrollView(.horizontal){
                                HStack(spacing: 20){
                                    ForEach(movieDetailVM.castDetails){ cast in
                                        VStack{
                                            if let image = movieDetailVM.images[cast.id]{
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(minWidth: 0, minHeight: 200, maxHeight: 300)
                                            } else {
                                                Rectangle()
                                                    .fill(.blue)
                                                    .frame(minWidth: 200, minHeight: 200, maxHeight: 300)
                                            }
                                            Text(cast.name)
                                                .font(.caption)
                                        }
                                    }
                                }
                            }
                        }
                        .foregroundColor(.black)
                    } else {
                        Text("Loading movie Details")
                            .font(.headline)
                            .bold()
                            .foregroundStyle(.white)
                    }
                }
            }
            .task {
                await movieDetailVM.getData(movieId: movieId)
            }
            .alert("OOPS..!", isPresented: .constant(showAlert)) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(movieDetailVM.errorMessage)
            }
        }
    }
}

//#Preview {
//    MovieDetailView(movieId: 1011985)
//}
