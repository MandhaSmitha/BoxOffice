//
//  MovieListServiceHandler.swift
//  BoxOffice
//
//  Created by Smitha Mandha on 7/10/18.
//  Copyright © 2018 SmithaReddy. All rights reserved.
//

import UIKit

protocol MovieListServiceProtocol: class {
    func fetchMovie(_ movieName: String, pageNumber: Int, isNewSearch: Bool, completionHandler: @escaping ((Bool, Data?, Error?)->Void))
}

class MovieListServiceHandler: NSObject, MovieListServiceProtocol {
    //MARK: - API call
    /**
     API call to fetch the movie list with name, movieName
     check the mimeType of the response to extend handling for other content types
     */
    func fetchMovie(_ movieName: String, pageNumber: Int, isNewSearch: Bool, completionHandler: @escaping ((Bool, Data?, Error?)->Void)) {
        let movieEndPoint: String = "\(APIConstants.baseURL)?api_key=\(APIConstants.apiKey)&query=\(movieName)&page=\(pageNumber)"
        guard let url = URL(string: movieEndPoint) else {
            completionHandler(false, nil, nil)
            return
        }
        let urlRequest = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                completionHandler(false, data, error)
                return
            }
            completionHandler(true, data, error)
        }
        task.resume()
    }
}
