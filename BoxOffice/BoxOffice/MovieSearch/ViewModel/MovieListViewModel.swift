//
//  MovieListViewModel.swift
//  BoxOffice
//
//  Created by Smitha Mandha on 7/8/18.
//  Copyright © 2018 SmithaReddy. All rights reserved.
//

import UIKit
import CoreData

struct MovieListViewModelConstants {
    static let genericTechnicalError = "Sorry, something went wrong. Please try again"
    static let noResultsMessage = "Sorry, could not find movies with the name, {movie_name}"
    static let maxRecentSearchesRequired = 10
}

class MovieListViewModel: NSObject {
    
    private var lastSearch = ""
    var moviesModel: MoviesModel = MoviesModel()
    var cellViewModels = [MovieListCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    var movieListServiceHandler: MovieListServiceProtocol
    /**
     Set of variables that bind the data and the UIViews
     */
    var reloadTableViewClosure: (()->())?
    var showAlertClosure: ((String)->())?
    var showRecentSearchesClosure: (()->())?
    var managedObjectContext: NSManagedObjectContext!

    init(serviceHandler: MovieListServiceProtocol, context: NSManagedObjectContext) {
        movieListServiceHandler = serviceHandler
        managedObjectContext = context
    }

    //MARK: - User action handlers
    /**
     Called when SearchBar is in focus
     Checks for user search data from previous searches
     Signals display of previous search data if available
     */
    func userTappedSearchBar() {
        if isRecentSearchDataAvailable() {
            showRecentSearchesClosure?()
        }
    }
    
    /**
     Called when user enter the name of a movie in the searchBar or
     when the user picks a movie from the recent searches list
     
     isNewSearch is used to distinguish between pagination and user explicitly searching for a movie
     */
    @objc func userSearchedForMovie(_ searchText: String? = nil, isNewSearch: Bool = false) {
        lastSearch = searchText ?? lastSearch
        if isNewSearch {
            resetMoviesModel()
            resetCellViewModels()
        } else if moviesModel.pageNumber == moviesModel.totalPages {
            return
        }
        
        movieListServiceHandler.fetchMovie(lastSearch, pageNumber: moviesModel.pageNumber+1,
                                           isNewSearch: isNewSearch) { [weak self] (isSuccess, responseData, error) in
            guard let `self` = self else { return }
            if isSuccess, let response = responseData {
                self.handleMovieResponse(responseData: response, isNewSearch: isNewSearch)
            } else {
                DispatchQueue.main.async {
                    self.showAlertClosure?(MovieListViewModelConstants.genericTechnicalError)
                }
            }
        }
    }
    
    /**
     reset moviesModel to its initial state
     */
    func resetMoviesModel() {
        moviesModel.pageNumber = 0
        moviesModel.totalPages = 0
        moviesModel.movies.removeAll()
    }
    
    /**
     reset cellViewModels to its initial state
     */
    func resetCellViewModels() {
        cellViewModels.removeAll()
    }

    /**
     Checks for user's previous search data stored using coredata
     returns true if data is available, false otherwise
     */
    
    func isRecentSearchDataAvailable() -> Bool {
        do {
            let fetchRequest : NSFetchRequest<RecentMovieSearch> = RecentMovieSearch.fetchRequest()
            do {
                let recentSearchData = try managedObjectContext.fetch(fetchRequest)
                if recentSearchData.count > 0 {
                    return true
                }
            } catch {
                print("Unable to fetch recent search data")
            }
        }
        return false
    }
    
    // MARK: - TableView data binding support
    var numberOfCells: Int {
        return cellViewModels.count
    }
    /**
     Returns data to be displayed in the cell at row, indexpath.row
     */
    func getDataForCell(at indexPath: IndexPath ) -> MovieListCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    //MARK: - Movie list response handling
    /**
     Handles movie list response data from the API
     */
    func handleMovieResponse(responseData: Data, isNewSearch: Bool) {
        do {
            guard let response = try JSONSerialization.jsonObject(with: responseData, options: [])
                as? [String: Any], let movieListResponse = response["results"] as? [[String: Any]],
                movieListResponse.count > 0 else {
                    let message = MovieListViewModelConstants.noResultsMessage.replacingOccurrences(of: "{movie_name}", with: lastSearch)
                    DispatchQueue.main.async { [weak self] in
                        self?.showAlertClosure?(message)
                    }
                    return
            }
            
            if isNewSearch {
                updateRecentSearchData()
            }
            parseMovieResponse(response)
            parseMovieListResponse(movieListResponse)
            populateCellViewModels(movies: moviesModel.movies)
        } catch  {
            DispatchQueue.main.async { [weak self] in
                self?.showAlertClosure?(MovieListViewModelConstants.genericTechnicalError)
            }
            return
        }
    }
    
    /**
     parse and populate data into moviesModel
     */
    func parseMovieResponse(_ response: [String: Any]) {
        moviesModel.pageNumber = response["page"] as? Int ?? 0
        moviesModel.totalPages = response["total_pages"] as? Int ?? 0
    }
    
    /**
     parse and populate data into movies array of moviesModel
     */
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

    /**
     Populates data into cellViewModels
     */
    func populateCellViewModels(movies: [MovieModel]) {
        for movie in movies {
            cellViewModels.append(createCellViewModel(movie: movie))
        }
    }
    
    /**
     Converts MovieModel into cellViewModel that can be used by the view
     */
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
    
    //MARK: - Coredata support for recent searches
    /**
     Add/update user search in coredata by deleting the oldest entry if number of
     stored searches is greaterThan or equalTo maxRecentSearchesRequired
     */
    func updateRecentSearchData() {
        let fetchRequest : NSFetchRequest<RecentMovieSearch> = RecentMovieSearch.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "movieName=%@", lastSearch)
        do {
            let recentSearchToUpdate = try managedObjectContext.fetch(fetchRequest)
            if recentSearchToUpdate.count > 0 {
                //Update timestamp of search text to current if movie exists in the DB
                recentSearchToUpdate.first?.createdAt = Date()
            } else {
                fetchRequest.predicate = nil
                let sort = NSSortDescriptor(key: #keyPath(RecentMovieSearch.createdAt), ascending: true)
                fetchRequest.sortDescriptors = [sort]
                let recentSearchData = try managedObjectContext.fetch(fetchRequest)
                /* Delete the oldest entry in the DB if the if maxRecentSearchesRequired number of entries exist
                 and insert the current search */
                if recentSearchData.count >= MovieListViewModelConstants.maxRecentSearchesRequired, let oldestSearch = recentSearchData.first {
                    managedObjectContext.delete(oldestSearch)
                    insertSearchIntoDb()
                } else {
                    insertSearchIntoDb()
                }
            }
            do {
                try managedObjectContext.save()
            } catch {
                print("Failed saving")
            }
        } catch {
            print("Unable to fetch recent search data")
        }
    }
    
    /**
     Insert search text into entity, RecentMovieSearch
    */
    func insertSearchIntoDb() {
        let entity = NSEntityDescription.entity(forEntityName: "RecentMovieSearch", in: managedObjectContext)!
        let recentSearch = NSManagedObject(entity: entity, insertInto: managedObjectContext)
        recentSearch.setValue(lastSearch, forKey: "movieName")
        recentSearch.setValue(Date(), forKey: "createdAt")
    }
}
