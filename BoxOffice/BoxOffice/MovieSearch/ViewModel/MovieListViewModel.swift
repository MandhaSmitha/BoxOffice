//
//  MovieListViewModel.swift
//  BoxOffice
//
//  Created by Smitha Mandha on 7/8/18.
//  Copyright © 2018 SmithaReddy. All rights reserved.
//

import UIKit

class MovieListViewModel: NSObject {
    
    private var lastSearch = ""
    var moviesModel: MoviesModel = MoviesModel()
    var cellViewModels = [MovieListCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    var reloadTableViewClosure: (()->())?
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    @objc func userSearchedForMovie(_ searchText: String? = nil, isNewSearch: Bool = false) {
        lastSearch = searchText ?? lastSearch
        if isNewSearch {
            resetMoviesModel()
            resetCellViewModels()
        } else if moviesModel.pageNumber == moviesModel.totalPages {
            return
        }
        fetchMovie(lastSearch, isNewSearch: isNewSearch, completionHandler: { [weak self] (isSuccess, responseData, error) in
            guard let `self` = self else { return }
            if isSuccess, let response = responseData {
                self.handleMovieResponse(responseData: response, isNewSearch: isNewSearch)
            } else {
                //handle error
            }
        })
    }
    
    func resetMoviesModel() {
        moviesModel.pageNumber = 0
        moviesModel.totalPages = 0
        moviesModel.movies.removeAll()
    }
    
    func resetCellViewModels() {
        cellViewModels.removeAll()
    }

    func getDataForCell(at indexPath: IndexPath ) -> MovieListCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func fetchMovie(_ movieName: String, isNewSearch: Bool, completionHandler: @escaping ((Bool, Data?, Error?)->Void)) {
        let movieEndPoint: String = "\(APIConstants.baseURL)?api_key=\(APIConstants.apiKey)&query=\(movieName)&page=\(moviesModel.pageNumber+1)"
        guard let url = URL(string: movieEndPoint) else {
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
    
    func handleMovieResponse(responseData: Data, isNewSearch: Bool) {
        do {
            guard let response = try JSONSerialization.jsonObject(with: responseData, options: [])
                as? [String: Any], let movieListResponse = response["results"] as? [[String: Any]] else {
                    print("error trying to convert data to JSON")
                    return
            }
            
            parseMovieResponse(response)
            parseMovieListResponse(movieListResponse)
            populateCellViewModels(movies: moviesModel.movies)
        } catch  {
            return
        }
    }
    
    func parseMovieResponse(_ response: [String: Any]) {
        moviesModel.pageNumber = response["page"] as? Int ?? 0
        moviesModel.totalPages = response["total_pages"] as? Int ?? 0
    }
    
    func parseMovieListResponse(_ movieListResponse: [[String: Any]]) {
        for movieResponse in movieListResponse {
            let posterPath = movieResponse["poster_path"] as? String
            let name = movieResponse["title"] as? String
            let releaseDate = movieResponse["release_date"] as? String
            let fullOverview = movieResponse["overview"] as? String
            
            let movieDetailModel = MovieModel(posterPath: posterPath,
                                              name: name,
                                              releaseDate: releaseDate,
                                              fullOverview: fullOverview)
            moviesModel.movies.append(movieDetailModel)
        }
    }

    func populateCellViewModels(movies: [MovieModel]) {
        for movie in movies {
            cellViewModels.append(createCellViewModel(movie: movie))
        }
    }
    
    func createCellViewModel(movie: MovieModel) -> MovieListCellViewModel {
        var posterURLString: String?
        if let posterURL = movie.posterPath {
            posterURLString = "\(APIConstants.posterImageBaseURL)\(posterURL)"
        }
        return MovieListCellViewModel(posterURL: posterURLString,
                                      nameText: movie.name ?? "",
                                      releaseDateText: movie.releaseDate ?? "--",
                                      fullOverviewText: movie.fullOverview ?? "")
    }
}
