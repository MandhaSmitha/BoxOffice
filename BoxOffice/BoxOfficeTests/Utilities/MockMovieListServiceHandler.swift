//
//  MockMovieListServiceHandler.swift
//  BoxOfficeTests
//
//  Created by Smitha Mandha on 7/10/18.
//  Copyright © 2018 SmithaReddy. All rights reserved.
//

import UIKit
@testable import BoxOffice

enum RequiredResponseType: String {
    case success
    case failure
}

class MockMovieListServiceHandler: MovieListServiceProtocol {
    func fetchMovie(_ movieName: String, pageNumber: Int, isNewSearch: Bool, completionHandler: @escaping ((Bool, Data?, Error?) -> Void)) {
        if movieName == RequiredResponseType.success.rawValue {
            let path = Bundle(for: type(of: self)).path(forResource: "MovieListResponse", ofType: "json")!
            let responseData = try! Data(contentsOf: URL(fileURLWithPath: path))
            completionHandler(true, responseData, nil)
        } else {
            completionHandler(false, nil, nil)
        }
    }
}
