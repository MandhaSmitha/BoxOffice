//
//  MovieSearchViewModel.swift
//  BoxOffice
//
//  Created by Smitha Mandha on 7/9/18.
//  Copyright © 2018 SmithaReddy. All rights reserved.
//

import UIKit
import CoreData

struct MovieSearchCellViewModel {
    var searchText: String
}

class MovieSearchViewModel: NSObject {
    var recentSearchData: [RecentMovieSearch]? {
        didSet {
            self.createCellViewModels()
        }
    }
    var cellViewModels = [MovieSearchCellViewModel]() {
        didSet {
            DispatchQueue.main.async {
                self.reloadTableViewClosure?()
            }
        }
    }
    var reloadTableViewClosure: (()->())?
    var managedObjectContext: NSManagedObjectContext!
    
    init(context: NSManagedObjectContext) {
        managedObjectContext = context
    }
    
    func loadUI() {
        fetchRecentSearchData()
    }
    
    //MARK: - TableView data binding support
    var numberOfCells: Int {
        return cellViewModels.count
    }
    /**
     Returns data to be displayed in the cell at row, indexpath.row
     */
    func getCellViewModel(at index: Int) -> MovieSearchCellViewModel {
        return cellViewModels[index]
    }
    
    //MARK: - Coredata support
    /**
     Get recent search data from the database
     */
    func fetchRecentSearchData() {
        do {
            let fetchRequest : NSFetchRequest<RecentMovieSearch> = RecentMovieSearch.fetchRequest()
            let sort = NSSortDescriptor(key: #keyPath(RecentMovieSearch.createdAt), ascending: true)
            fetchRequest.sortDescriptors = [sort]
            do {
                recentSearchData = try managedObjectContext.fetch(fetchRequest)
            } catch {
                print("Unable to fetch recent search data")
            }
        }
    }
    
    //MARK: - Process coredata models into UI understandable models
    /**
     Populates data into cellViewModels
     */
    func createCellViewModels() {
        guard let recentSearches = recentSearchData else {
            return
        }
        var viewModels = [MovieSearchCellViewModel]()
        for recentSearch in recentSearches {
            if let cellViewModel = createCellViewModel(from: recentSearch) {
                viewModels.append(cellViewModel)
            }
        }
        cellViewModels = viewModels
    }
    
    /**
     Converts RecentMovieSearch into MovieSearchCellViewModel that can be used by the view
     */
    func createCellViewModel(from recentSearchModel: RecentMovieSearch) -> MovieSearchCellViewModel? {
        guard let searchText = recentSearchModel.movieName else {
            return nil
        }
        return MovieSearchCellViewModel(searchText: searchText)
    }
}
