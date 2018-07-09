//
//  MovieModel.swift
//  BoxOffice
//
//  Created by Smitha Mandha on 7/8/18.
//  Copyright © 2018 SmithaReddy. All rights reserved.
//

import UIKit

struct MoviesModel {
    var movies = [MovieModel]()
    var pageNumber = 0
    var totalPages = 0
}

struct MovieModel {
    var posterPath: String?
    var name: String?
    var releaseDate: String?
    var fullOverview: String?
}
