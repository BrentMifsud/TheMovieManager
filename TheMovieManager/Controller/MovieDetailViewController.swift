//
//  MovieDetailViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var watchlistBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButtonItem: UIBarButtonItem!
    
    var movie: Movie!
    
    var isWatchlist: Bool {
        return MovieModel.watchlist.contains(movie)
    }
    
    var isFavorite: Bool {
        return MovieModel.favorites.contains(movie)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = movie.title
		imageView.image = UIImage(named: "PosterPlaceholder")

		TMDBClient.downloadPosterImage(posterPath: movie.posterPath ?? "", completion: handleDownloadPosterImage(data:error:))
        
        toggleBarButton(watchlistBarButtonItem, enabled: isWatchlist)
        toggleBarButton(favoriteBarButtonItem, enabled: isFavorite)
        
    }

	func handleDownloadPosterImage(data: Data?,error: Error?) {
		guard let data = data else { return }

		DispatchQueue.main.async {
			self.imageView.image = UIImage(data: data)
		}
	}
    
    @IBAction func watchlistButtonTapped(_ sender: UIBarButtonItem) {
        TMDBClient.markWatchlist(movieId: movie.id, watchlist: !isWatchlist, completion: handleWatchlistResponse(success:error:))
    }

	func handleWatchlistResponse(success: Bool, error: Error?){
		if success {
			if isWatchlist{
				MovieModel.watchlist = MovieModel.watchlist.filter() { $0 != self.movie }
			} else {
				MovieModel.watchlist.append(self.movie)
			}
			toggleBarButton(watchlistBarButtonItem, enabled: isWatchlist)
		}
	}
    
    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {
		TMDBClient.markFavorite(movieId: movie.id, favorite: !isFavorite, completion: handleFavoriteButtonTapped(success:error:))
    }

	func handleFavoriteButtonTapped(success: Bool, error: Error?){
		if success {
			if isFavorite {
				MovieModel.favorites = MovieModel.favorites.filter() {$0 != self.movie}
			} else {
				MovieModel.favorites.append(self.movie)
			}
			toggleBarButton(favoriteBarButtonItem, enabled: isFavorite)
		}
	}
    
    func toggleBarButton(_ button: UIBarButtonItem, enabled: Bool) {
        if enabled {
            button.tintColor = UIColor.primaryDark
        } else {
            button.tintColor = UIColor.gray
        }
    }
    
    
}
