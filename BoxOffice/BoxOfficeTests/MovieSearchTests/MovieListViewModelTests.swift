//
//  MovieListViewModelTests.swift
//  BoxOfficeTests
//
//  Created by Smitha Mandha on 7/10/18.
//  Copyright © 2018 SmithaReddy. All rights reserved.
//

import XCTest
import CoreData
@testable import BoxOffice

class MovieListViewModelTests: XCTestCase {
    
    var movieListViewModel: MovieListViewModel!
    var responseData: Data!
    var jsonResponse: [String: Any]!
    var movieListResponse: [[String: Any]]!
    
    override func setUp() {
        super.setUp()
        movieListViewModel = MovieListViewModel(serviceHandler: MockMovieListServiceHandler(),
                                                context: MockCoreDataUtility.managedObjectContext())
        let path = Bundle(for: type(of: self)).path(forResource: "MovieListResponse", ofType: "json")!
        responseData = try! Data(contentsOf: URL(fileURLWithPath: path))
        jsonResponse = try! JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
        movieListResponse = jsonResponse["results"] as? [[String: Any]]
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCreateCellViewModel() {
        let movieModel = MovieModel(posterPath: "/kBf3g9crrADGMc2AMAMlLBgSm2h.jpg",
                                    name: "Batman",
                                    releaseDate: "1989-06-23",
                                    fullOverview: "The Dark Knight of Gotham City begins his war on crime with his first major enemy being the clownishly homicidal Joker, who has seized control of Gotham's underworld.")
        let cellViewModel = movieListViewModel.createCellViewModel(movie: movieModel)
        XCTAssertEqual(cellViewModel.nameText, "Batman")
        XCTAssertEqual(cellViewModel.releaseDateText, "1989-06-23")
        XCTAssertEqual(cellViewModel.fullOverviewText, "The Dark Knight of Gotham City begins his war on crime with his first major enemy being the clownishly homicidal Joker, who has seized control of Gotham's underworld.")
        XCTAssertEqual(cellViewModel.posterURL, "\(APIConstants.posterImageBaseURL)/kBf3g9crrADGMc2AMAMlLBgSm2h.jpg")
    }
    
    func testCreateCellViewModelWithEmptyValues() {
        let movieModel = MovieModel(posterPath: nil,
                                    name: nil,
                                    releaseDate: nil,
                                    fullOverview: nil)
        let cellViewModel = movieListViewModel.createCellViewModel(movie: movieModel)
        XCTAssertEqual(cellViewModel.nameText, "")
        XCTAssertEqual(cellViewModel.releaseDateText, "--")
        XCTAssertEqual(cellViewModel.fullOverviewText, "")
        XCTAssertNil(cellViewModel.posterURL)
    }
    
    func testParseMovieResponse() {
        movieListViewModel.parseMovieResponse(jsonResponse)
        XCTAssertEqual(movieListViewModel.moviesModel.pageNumber, 1)
        XCTAssertEqual(movieListViewModel.moviesModel.totalPages, 6)
    }
    
    func testParseMovieListResponse() {
        movieListViewModel.parseMovieListResponse(movieListResponse)
        XCTAssertNotNil(movieListViewModel.moviesModel.movies)
        XCTAssertEqual(movieListViewModel.moviesModel.movies.count, 20)
    }
    
    func testPopulateCellViewModels() {
        movieListViewModel.parseMovieListResponse(movieListResponse)
        movieListViewModel.populateCellViewModels(movies: movieListViewModel.moviesModel.movies)
        XCTAssertNotNil(movieListViewModel.cellViewModels)
        XCTAssertEqual(movieListViewModel.cellViewModels.count, 20)
    }
    
    func testHandleMovieResponse() {
        movieListViewModel.handleMovieResponse(responseData: responseData, isNewSearch: true)
        XCTAssertEqual(movieListViewModel.moviesModel.pageNumber, 1)
        XCTAssertEqual(movieListViewModel.moviesModel.totalPages, 6)
        XCTAssertNotNil(movieListViewModel.moviesModel.movies)
        XCTAssertEqual(movieListViewModel.moviesModel.movies.count, 20)
        XCTAssertNotNil(movieListViewModel.cellViewModels)
        XCTAssertEqual(movieListViewModel.cellViewModels.count, 20)
    }
    
    func testResetMoviesModel() {
        movieListViewModel.handleMovieResponse(responseData: responseData, isNewSearch: true)
        movieListViewModel.resetMoviesModel()
        XCTAssertEqual(movieListViewModel.moviesModel.movies.count, 0)
        XCTAssertEqual(movieListViewModel.moviesModel.pageNumber, 0)
        XCTAssertEqual(movieListViewModel.moviesModel.totalPages, 0)
    }
    
    func testResetCellViewModels() {
        movieListViewModel.handleMovieResponse(responseData: responseData, isNewSearch: true)
        movieListViewModel.resetCellViewModels()
        XCTAssertEqual(movieListViewModel.cellViewModels.count, 0)
    }
    
    func testIsRecentSearchDataAvailable() {
        let isRecentSearchAvailable = movieListViewModel.isRecentSearchDataAvailable()
        XCTAssertFalse(isRecentSearchAvailable)
    }
    
    func testIsRecentSearchDataAvailableWithValues() {
        let entity = NSEntityDescription.entity(forEntityName: "RecentMovieSearch",
                                                in: movieListViewModel.managedObjectContext)!
        let recentSearch = NSManagedObject(entity: entity, insertInto: movieListViewModel.managedObjectContext)
        recentSearch.setValue("Batman", forKey: "movieName")
        recentSearch.setValue(Date(), forKey: "createdAt")
        let isRecentSearchAvailable = movieListViewModel.isRecentSearchDataAvailable()
        XCTAssertTrue(isRecentSearchAvailable)
    }
    
    func testGetDataForCell() {
        movieListViewModel.parseMovieListResponse(movieListResponse)
        movieListViewModel.populateCellViewModels(movies: movieListViewModel.moviesModel.movies)
        let cellViewModel = movieListViewModel.getDataForCell(at: IndexPath(row: 0, section: 0))
        XCTAssertNotNil(cellViewModel)
        XCTAssertEqual(cellViewModel.nameText, "Batman")
        XCTAssertEqual(cellViewModel.releaseDateText, "1989-06-23")
        XCTAssertEqual(cellViewModel.posterURL!, "\(APIConstants.posterImageBaseURL)/kBf3g9crrADGMc2AMAMlLBgSm2h.jpg")
        XCTAssertEqual(cellViewModel.fullOverviewText, "The Dark Knight of Gotham City begins his war on crime with his first major enemy being the clownishly homicidal Joker, who has seized control of Gotham's underworld.")
    }
    
    func testInsertSearchIntoDb() {
        movieListViewModel.userSearchedForMovie("Batman", isNewSearch: true)
        movieListViewModel.insertSearchIntoDb()
        let fetchRequest : NSFetchRequest<RecentMovieSearch> = RecentMovieSearch.fetchRequest()
        let recentSearchData = try! movieListViewModel.managedObjectContext.fetch(fetchRequest)
        XCTAssertNotNil(recentSearchData)
        XCTAssertTrue(recentSearchData.count > 0)
    }
    
    func testDeletionWhenMaxEntriesExist() {
        let entity = NSEntityDescription.entity(forEntityName: "RecentMovieSearch",
                                                in: movieListViewModel.managedObjectContext)!
        var i = 0
        while i < 11 {
            let recentSearch = NSManagedObject(entity: entity, insertInto: movieListViewModel.managedObjectContext)
            recentSearch.setValue("Movie\(i)", forKey: "movieName")
            recentSearch.setValue(Date(), forKey: "createdAt")
            i += 1
        }
        movieListViewModel.updateRecentSearchData()
        let fetchRequest : NSFetchRequest<RecentMovieSearch> = RecentMovieSearch.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "movieName=%@", "Movie0")
        let recentSearchData = try! movieListViewModel.managedObjectContext.fetch(fetchRequest)
        XCTAssertTrue(recentSearchData.count == 0)
    }
}
