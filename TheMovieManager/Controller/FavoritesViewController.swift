//
//  FavoritesViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
	lazy var refresh: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = .black
		refreshControl.addTarget(self, action: #selector(refreshFavorites), for: .valueChanged)

		return refreshControl
	}()


	var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

		tableView.refreshControl = refresh

		refreshFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! MovieDetailViewController
            detailVC.movie = MovieModel.favorites[selectedIndex]
        }
    }

	@objc func refreshFavorites() {
		TMDBClient.getFavorites() { movies, error in
			MovieModel.favorites = movies

			unowned let favoriteVC = self

			DispatchQueue.main.async {
				favoriteVC.tableView.reloadData()
			}

			let deadline = DispatchTime.now() + .milliseconds(500)
			DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
				favoriteVC.refresh.endRefreshing()
			})
		}
	}

}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MovieModel.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell")!

		isDownloading(true)
        
        let movie = MovieModel.favorites[indexPath.row]
        
        cell.textLabel?.text = movie.title
		cell.imageView?.image = UIImage(named: "MoviePlaceholder")

		if let posterPath = movie.posterPath {
			TMDBClient.downloadPosterImage(posterPath: posterPath) { (data, error) in
				guard let data = data else { return }

				unowned let favoritesVC = self

				cell.imageView?.image = UIImage(data: data)
				cell.setNeedsLayout()
				favoritesVC.isDownloading(false)
			}
		}
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "showDetail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }

		let selectedMovie = MovieModel.favorites[indexPath.row]

		TMDBClient.markFavorite(movieId: selectedMovie.id, favorite: false) { (success, error) in
			if success {
				MovieModel.favorites.remove(at: indexPath.row)
				tableView.reloadData()
			}
		}
	}
    
}
