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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
		TMDBClient.getRequestToken(completion: handleRequestToken(success:error:))
//		performSegue(withIdentifier: "completeLogin", sender: nil)
    }
    
    @IBAction func loginViaWebsiteTapped() {
        performSegue(withIdentifier: "completeLogin", sender: nil)
    }

	func handleRequestToken(success: Bool, error: Error?){
		if success {
			print("Request Token: \(TMDBClient.Auth.requestToken)")
			DispatchQueue.main.async {
				TMDBClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleLogin(success:error:))
			}
		} else {
			print(error ?? "Get Request Token Failed")
		}
	}

	func handleLogin(success: Bool, error: Error?) {
		if success {
			print("Request Token: \(TMDBClient.Auth.requestToken)")
		} else {
			print(error ?? "Get Request Token Failed")
		}
	}
    
}
