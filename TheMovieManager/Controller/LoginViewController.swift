//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
	
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var loginViaWebsiteButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		emailTextField.text = ""
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
		emailTextField.isEnabled = !loggingIn
		passwordTextField.isEnabled = !loggingIn
		loginButton.isEnabled = !loggingIn
		loginViaWebsiteButton.isEnabled = !loggingIn
	}
	
}

extension LoginViewController {
	func handleRequestTokenResponse(success: Bool, error: Error?){
		if success {
			TMDBClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleLoginResponse(success:error:))
		} else {
			setLoggingIn(false)
			print(error ?? "Get Request Token Failed")
		}
	}

	func handleLoginResponse(success: Bool, error: Error?) {
		if success {
			TMDBClient.getSessionId(completion: self.handleSessionIDResponse(success:error:))
		} else {
			setLoggingIn(false)
			print(error ?? "Get Request Token Failed")
		}
	}

	func handleSessionIDResponse(success: Bool, error: Error?) {
		setLoggingIn(false)
		if success {
			self.performSegue(withIdentifier: "completeLogin", sender: nil)
		} else {
			print(error ?? "Get Session ID Failed")
		}
	}
}
