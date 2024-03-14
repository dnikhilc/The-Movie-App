//
//  MovieCellView.swift
//  The Movie App
//
//  Created by Nikhil Doppalapudi on 3/12/24.
//

import SwiftUI

struct MovieCellView: View {
    
    @EnvironmentObject var movieVM: MovieListViewModel
    
    var movieDetails : Result
    
    var body: some View {
        ZStack(alignment: .bottom){
            if let image = movieVM.images[movieDetails.id]{
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(8)
                    .frame(minWidth: 0, minHeight: 300, maxHeight: 500)
            }
//            Rectangle()
//                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 300, maxHeight: 500)
//                .foregroundColor(.mint)
            HStack(){
                Text(movieDetails.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding()
                Spacer()
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.red)
                Text(String(movieDetails.voteCount))
                    .foregroundStyle(.white)
                    .font(.subheadline)
            }
            .background(LinearGradient(gradient: Gradient(colors: [.black.opacity(0.7), .clear]), startPoint: .bottom, endPoint: .top))
        }
    }
}

//#Preview {
//    MovieCellView(movieDetails: )
//}
