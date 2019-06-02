//
//  WatchlistViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class WatchlistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

	lazy var refresh: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = .black
		refreshControl.addTarget(self, action: #selector(refreshWatchlist), for: .valueChanged)

		return refreshControl
	}()
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

		tableView.refreshControl = refresh
        
        refreshWatchlist()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! MovieDetailViewController
            detailVC.movie = MovieModel.watchlist[selectedIndex]
        }
    }

	@objc func refreshWatchlist() {
		TMDBClient.getWatchlist() { movies, error in
			MovieModel.watchlist = movies

			unowned let watchlistVC = self

			DispatchQueue.main.async {
				watchlistVC.tableView.reloadData()
			}

			let deadline = DispatchTime.now() + .milliseconds(500)
			DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
				watchlistVC.refresh.endRefreshing()
			})
		}
	}

}

extension WatchlistViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MovieModel.watchlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell")!
        
		isDownloading(true)

		let movie = MovieModel.watchlist[indexPath.row]

		cell.textLabel?.text = movie.title
		cell.imageView?.image = UIImage(named: "MoviePlaceholder")

		if let posterPath = movie.posterPath {
			TMDBClient.downloadPosterImage(posterPath: posterPath) { (data, error) in
				guard let data = data else { return }

				unowned let watchlistVC = self

				cell.imageView?.image = UIImage(data: data)
				cell.setNeedsLayout()
				watchlistVC.isDownloading(false)
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

		let selectedMovie = MovieModel.watchlist[indexPath.row]

		TMDBClient.markWatchlist(movieId: selectedMovie.id, watchlist: false) { (success, error) in
			if success {
				MovieModel.watchlist.remove(at: indexPath.row)
				tableView.reloadData()
			}
		}
	}
}
