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
            self.reloadTableViewClosure?()
        }
    }
    var reloadTableViewClosure: (()->())?
    
    override init() {
        super.init()
    }
    
    func loadUI() {
        fetchRecentSearchData()
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }

    func getCellViewModel(at index: Int) -> MovieSearchCellViewModel {
        return cellViewModels[index]
    }
    
    func fetchRecentSearchData() {
        let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let fetchRequest : NSFetchRequest<RecentMovieSearch> = RecentMovieSearch.fetchRequest()
            let sort = NSSortDescriptor(key: #keyPath(RecentMovieSearch.createdAt), ascending: true)
            fetchRequest.sortDescriptors = [sort]
            do {
                recentSearchData = try viewContext.fetch(fetchRequest)
            } catch {
                print("Unable to fetch recent search data")
            }
        }
    }
    
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
    
    func createCellViewModel(from recentSearchModel: RecentMovieSearch) -> MovieSearchCellViewModel? {
        guard let searchText = recentSearchModel.movieName else {
            return nil
        }
        return MovieSearchCellViewModel(searchText: searchText)
    }
}
