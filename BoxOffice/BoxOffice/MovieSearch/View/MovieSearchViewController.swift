//
//  MovieSearchViewController.swift
//  BoxOffice
//
//  Created by Smitha Mandha on 7/9/18.
//  Copyright © 2018 SmithaReddy. All rights reserved.
//

import UIKit

protocol MovieSearchControllerDelegate {
    func userTappedMovie(_ movieName: String)
}

class MovieSearchViewController: UITableViewController {
    lazy var viewModel: MovieSearchViewModel = {
        return MovieSearchViewModel(context: CoreDataUtility.shared.managedObjectContext)
    }()
    var delegate: MovieSearchControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupClosures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadUI()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupClosures() {
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableviewCell", for: indexPath)
        cell.textLabel?.text = viewModel.getCellViewModel(at: indexPath.row).searchText
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.userTappedMovie(viewModel.getCellViewModel(at: indexPath.row).searchText)
    }
}
