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
		TMDBClient.getRequestToken(completion: handleRequestToken(success:error:))
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
	
	func handleRequestToken(success: Bool, error: Error?){
		if success {
			TMDBClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleLogin(success:error:))
		} else {
			setLoggingIn(false)
			print(error ?? "Get Request Token Failed")
		}
	}
	
	func handleLogin(success: Bool, error: Error?) {
		if success {
			TMDBClient.getSessionId(completion: self.handleSessionID(success:error:))
		} else {
			setLoggingIn(false)
			print(error ?? "Get Request Token Failed")
		}
	}
	
	func handleSessionID(success: Bool, error: Error?) {
		setLoggingIn(false)
		if success {
			self.performSegue(withIdentifier: "completeLogin", sender: nil)
		} else {
			print(error ?? "Get Session ID Failed")
		}
	}

	func setLoggingIn(_ loggingIn: Bool) {
		if loggingIn {
			activityIndicator.startAnimating()
		} else {
			activityIndicator.stopAnimating()
		}
	}
	
}
