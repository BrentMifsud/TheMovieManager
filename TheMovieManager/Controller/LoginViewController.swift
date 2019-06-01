//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
	
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var loginViaWebsiteButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		usernameTextField.text = ""
		passwordTextField.text = ""
	}
	
	@IBAction func loginTapped(_ sender: UIButton) {
		setLoggingIn(true)
		TMDBClient.getRequestToken(completion: handleRequestTokenResponse(success:error:))
	}
	
	@IBAction func loginViaWebsiteTapped() {
		setLoggingIn(true)
		TMDBClient.getRequestToken { (success, error) in
			if success{
				DispatchQueue.main.async {
					UIApplication.shared.open(TMDBClient.Endpoints.webAuth.url, options:[:], completionHandler: nil)
				}
			}
		}
	}

	func setLoggingIn(_ loggingIn: Bool) {
		if loggingIn {
			activityIndicator.startAnimating()
		} else {
			activityIndicator.stopAnimating()
		}
		usernameTextField.isEnabled = !loggingIn
		passwordTextField.isEnabled = !loggingIn
		loginButton.isEnabled = !loggingIn
		loginViaWebsiteButton.isEnabled = !loggingIn
	}

	func showLoginFailure(message: String) {
		let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
		alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		show(alertVC, sender: nil)
	}
	
}

extension LoginViewController {
	func handleRequestTokenResponse(success: Bool, error: Error?){
		if success {
			TMDBClient.login(username: self.usernameTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleLoginResponse(success:error:))
		} else {
			setLoggingIn(false)
			showLoginFailure(message: error?.localizedDescription ?? "")
		}
	}

	func handleLoginResponse(success: Bool, error: Error?) {
		if success {
			TMDBClient.getSessionId(completion: self.handleSessionIDResponse(success:error:))
		} else {
			setLoggingIn(false)
			showLoginFailure(message: error?.localizedDescription ?? "")
		}
	}

	func handleSessionIDResponse(success: Bool, error: Error?) {
		setLoggingIn(false)
		if success {
			self.performSegue(withIdentifier: "completeLogin", sender: nil)
		} else {
			showLoginFailure(message: error?.localizedDescription ?? "")
		}
	}
}
