//
//  NetworkHelper.swift
//  The Movie App
//
//  Created by Nikhil Doppalapudi on 3/12/24.
//

import Foundation

protocol NetworkServiceProtocl {
    
//    func fetchData(url: String) async throws -> ([Result], Int)
    func fetchImage(url: String) async throws -> Data
//    func fetchDataFromAPI(url: String) async throws -> MovieModel
    func fetchData<T: Decodable>(url: String) async throws -> T
}


class NetworkHelper : NetworkServiceProtocl{
    
    
    func fetchData<T>(url: String) async throws -> T where T : Decodable {
//        print("Coming to genric fetchData method.")
        guard let apiURL = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        let authToken = ConfigurationManager.shared.authToken
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        
        do{
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.badResponse((response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            let decodedData = try JSONDecoder().decode(T.self, from: data)
//            print("Came here got network details \(decodedData)")
            return decodedData
        } catch let decodingError as DecodingError{
            throw NetworkError.decodingError(decodingError)
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    
    func fetchImage(url: String) async throws -> Data{
        guard let imageURL = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: imageURL)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badResponse((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        return data
    }
}

enum NetworkError : Error{
    case invalidURL
    case requestFailed(Error)
    case badResponse(Int)
    case decodingError(Error)
}
