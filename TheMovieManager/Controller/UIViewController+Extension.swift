//
//  UIViewController+Extension.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

extension UIViewController {
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
		TMDBClient.logout { (success, error) in
			DispatchQueue.main.async {
				self.dismiss(animated: true, completion: nil)
			}
		}
    }

	func isDownloading(_ downloading: Bool) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = downloading
	}
}
