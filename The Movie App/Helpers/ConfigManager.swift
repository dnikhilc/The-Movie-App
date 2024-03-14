//
//  ConfigManager.swift
//  The Movie App
//
//  Created by Nikhil Doppalapudi on 3/14/24.
//

import Foundation

class ConfigurationManager {
    static let shared = ConfigurationManager()

    var baseURL: String = ""
    var imageBaseURL: String = ""
    private(set) var authToken: String = ""
//    var authToken: String {
//            return "Bearer API_TOKEN"
//        }

    private init() {
        loadURLsFromPlist()
    }

    private func loadURLsFromPlist() {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            baseURL = dict["baseURL"] as? String ?? ""
            imageBaseURL = dict["imageBaseURL"] as? String ?? ""
            if let token = dict["API_KEY"] {
                authToken = "Bearer \(token)"
            }
        }
    }
}
