//
//  MovieListViewController.swift
//  BoxOffice
//
//  Created by Smitha Mandha on 7/8/18.
//  Copyright © 2018 SmithaReddy. All rights reserved.
//

import UIKit

class MovieListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    lazy var viewModel: MovieListViewModel = {
        return MovieListViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSearchController()
        setupClosures()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupView() {
        self.title = NSLocalizedString("MovieListPage_Title", comment: "Movie list page title")
    }
    
    func setupSearchController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let movieSearchViewController = storyboard.instantiateViewController(withIdentifier: "MovieSearchViewController") as! MovieSearchViewController
        movieSearchViewController.delegate = self
        searchController = UISearchController(searchResultsController: movieSearchViewController)
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = true
        definesPresentationContext = true
        extendedLayoutIncludesOpaqueBars = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func setupClosures() {
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        viewModel.showAlertClosure = { [weak self] (message) in
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(action)
                self?.present(alertController, animated: true, completion: nil)
            }
        }
        viewModel.showRecentSearchesClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.searchController.searchResultsController?.view.isHidden = false
            }
        }
    }
}

extension MovieListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieListTableViewCell.identifier, for: indexPath) as? MovieListTableViewCell else {
            fatalError("Cell not exists in storyboard")
        }
        cell.viewModel = viewModel.getDataForCell(at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.numberOfCells - 1 {
            didScrollToEndOfPage()
        }
    }
    
    func didScrollToEndOfPage() {
        viewModel.userSearchedForMovie()
    }
}

extension MovieListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.userSearchedForMovie(searchBar.text, isNewSearch: true)
        searchController.isActive = false
    }
}

extension MovieListViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        viewModel.userTappedSearchBar()
    }
}

extension MovieListViewController: MovieSearchControllerDelegate {
    func userTappedMovie(_ movieName: String) {
        viewModel.userSearchedForMovie(movieName, isNewSearch: true)
        searchController.isActive = false
    }
}
