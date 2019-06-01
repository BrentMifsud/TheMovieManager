//
//  SearchViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var movies = [Movie]()
    
    var selectedIndex = 0

	var currentSearchTask: URLSessionTask?

	var currentPageNumber: Int = 0

	var maxPageCount: Int = 0
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! MovieDetailViewController
            detailVC.movie = movies[selectedIndex]
        }
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		currentSearchTask?.cancel()
		currentSearchTask = TMDBClient.searchForMovie(query: searchText) { (movieResults, error) in
			if let movieResults = movieResults {
				weak var searchVC = self
				searchVC?.movies = movieResults.results
				searchVC?.currentPageNumber = movieResults.page
				searchVC?.maxPageCount = movieResults.totalPages
				searchVC?.tableView.reloadData()
			}
		}
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell")!
        
		isDownloading(true)

		let movie = movies[indexPath.row]
        
        cell.textLabel?.text = "\(movie.title)"

		if !movie.releaseYear.isEmpty {
			cell.textLabel?.text?.append(" - \(movie.releaseYear)")
		}

		cell.imageView?.image = UIImage(named: "MoviePlaceholder")

		if let posterPath = movie.posterPath {
			TMDBClient.downloadPosterImage(posterPath: posterPath) { (data, error) in
				guard let data = data else { return }

				unowned let searchVC = self

				cell.imageView?.image = UIImage(data: data)
				cell.setNeedsLayout()
				searchVC.isDownloading(false)
			}
		}
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "showDetail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard currentPageNumber > 0 else { return }
		guard maxPageCount > 0 else { return }
		guard currentPageNumber + 1 <= maxPageCount else { return }
		guard indexPath.row == movies.count-1 else { return }

		if let query = searchBar.text {
			isDownloading(true)
			TMDBClient.searchForMovie(query: query, page: currentPageNumber + 1) { (movieResults, error) in
				if let movieResults = movieResults {
					weak var searchVC = self
					searchVC?.movies.append(contentsOf: movieResults.results)
					searchVC?.tableView.reloadData()
					searchVC?.currentPageNumber = movieResults.page
					searchVC?.maxPageCount = movieResults.totalPages
				}
			}
			isDownloading(false)
		}
	}
    
}
