//
//  MovieSearchViewModelTests.swift
//  BoxOfficeTests
//
//  Created by Smitha Mandha on 7/10/18.
//  Copyright © 2018 SmithaReddy. All rights reserved.
//

import XCTest
import CoreData
@testable import BoxOffice

class MovieSearchViewModelTests: XCTestCase {
    
    var movieSearchViewModel: MovieSearchViewModel!
    var managedObjectContext: NSManagedObjectContext!
    override func setUp() {
        super.setUp()
        managedObjectContext = MockCoreDataUtility.managedObjectContext()
        movieSearchViewModel = MovieSearchViewModel(context: managedObjectContext)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /**
     Step 1: Insert one record
     Step 2: Fetch data from RecentMovieSearch entity
     Step 3: Test it!!
     */
    func testCreateCellViewModel() {
        let fetchRequest : NSFetchRequest<RecentMovieSearch> = RecentMovieSearch.fetchRequest()
        /** Insert */
        let entity = NSEntityDescription.entity(forEntityName: "RecentMovieSearch", in: managedObjectContext)!
        let recentSearch = NSManagedObject(entity: entity, insertInto: managedObjectContext)
        recentSearch.setValue("Batman", forKey: "movieName")
        recentSearch.setValue(Date(), forKey: "createdAt")
        /** Fetch */
        let recentSearchData = try! managedObjectContext.fetch(fetchRequest)
        /** Test */
        let cellViewModel = movieSearchViewModel.createCellViewModel(from: recentSearchData.last!)
        XCTAssertNotNil(cellViewModel)
        XCTAssertEqual(cellViewModel!.searchText, "Batman")
    }
    
    func testFetchRecentSearchData() {
        /** Insert */
        let entity = NSEntityDescription.entity(forEntityName: "RecentMovieSearch", in: managedObjectContext)!
        let recentSearch = NSManagedObject(entity: entity, insertInto: managedObjectContext)
        recentSearch.setValue("Batman", forKey: "movieName")
        recentSearch.setValue(Date(), forKey: "createdAt")
        
        /** Fetch */
        let fetchRequest : NSFetchRequest<RecentMovieSearch> = RecentMovieSearch.fetchRequest()
        let recentSearchData = try! managedObjectContext.fetch(fetchRequest)
        /** Test */
        XCTAssertNotNil(recentSearchData)
        movieSearchViewModel.fetchRecentSearchData()
        XCTAssertNotNil(movieSearchViewModel.recentSearchData)
        XCTAssertTrue(movieSearchViewModel.recentSearchData!.count > 0)
    }
    
    func testGetCellViewModel() {
        /** Insert */
        let entity = NSEntityDescription.entity(forEntityName: "RecentMovieSearch", in: managedObjectContext)!
        let recentSearch = NSManagedObject(entity: entity, insertInto: managedObjectContext)
        recentSearch.setValue("Batman", forKey: "movieName")
        recentSearch.setValue(Date(), forKey: "createdAt")
        /** Test */
        movieSearchViewModel.fetchRecentSearchData()
        let cellViewModel = movieSearchViewModel.getCellViewModel(at: 0)
        XCTAssertNotNil(cellViewModel)
        XCTAssertEqual(cellViewModel.searchText, "Batman")
    }
}
