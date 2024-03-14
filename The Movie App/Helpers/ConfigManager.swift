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
    var authToken: String {
            return "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjNjliMDk2NTI2OGVkNTY2MTgzZmQ1Y2IzMDljMDlmNCIsInN1YiI6IjY1ZjBjMTEyZDIzNmU2MDE4NjRmMmY0YSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.6I_pX6dBrOcEgPyol8U6QEla3EnqRzlXBK5ovP82jdg"
        }

    private init() {
        loadURLsFromPlist()
    }

    private func loadURLsFromPlist() {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            baseURL = dict["baseURL"] as? String ?? ""
            imageBaseURL = dict["imageBaseURL"] as? String ?? ""
        }
    }
}
