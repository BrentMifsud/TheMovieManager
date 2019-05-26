//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class TMDBClient {
    
    static let apiKey = "ENTER API KEY HERE"
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        
        case getWatchlist
		case getRequestToken
		case login
		case getSessionId
		case webAuth
        
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
			case .getRequestToken: return Endpoints.base + "/authentication/token/new" + Endpoints.apiKeyParam
			case .login: return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
			case .getSessionId: return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
			case .webAuth: return "https://www.themoviedb.org/authenticate/\(Auth.requestToken)?redirect_to=themoviemanager:authenticate"
			}
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getWatchlist.url) { data, response, error in
            guard let data = data else {
                completion([], error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(MovieResults.self, from: data)
                completion(responseObject.results, nil)
            } catch {
                completion([], error)
            }
        }
        task.resume()
    }

	class func getRequestToken(completion: @escaping (Bool, Error?) -> Void) {
		let task = URLSession.shared.dataTask(with: Endpoints.getRequestToken.url) { (data, response, error) in
			guard let data = data else {
				completion(false, error)
				return
			}

			let decoder = JSONDecoder()
			do{
				let responseObject = try decoder.decode(RequestTokenResponse.self, from: data)
				completion(true, nil)

				Auth.requestToken = responseObject.requestToken
			} catch {
				completion(false, error)
			}
		}
		task.resume()
	}

	class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void){
		let body = LoginRequest(username: username, password: password, requestToken: Auth.requestToken)
		var request = URLRequest(url: Endpoints.login.url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")

		do {
			request.httpBody = try JSONEncoder().encode(body)
		} catch {
			print("Failed to Encode Login Request into JSON")
			completion(false, error)
		}

		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let data = data else {
				completion(false, error)
				return
			}

			do {
				let responseObject = try JSONDecoder().decode(RequestTokenResponse.self, from: data)
				Auth.requestToken = responseObject.requestToken
				completion(true, nil)
			} catch {
				print("Failed to decode Login Token Response")
				completion(false, error)
			}
		}
		task.resume()
	}

	class func	getSessionId(completion: @escaping (Bool, Error?) -> Void){
		let body = PostSession(requestToken: Auth.requestToken)
		var request = URLRequest(url: Endpoints.getSessionId.url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try! JSONEncoder().encode(body)

		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let data = data else {
				completion(false, error)
				return
			}

			do {
				let responseObject = try JSONDecoder().decode(SessionResponse.self, from: data)
				Auth.sessionId = responseObject.sessionId
				completion(true, nil)
			} catch {
				print("Failed to decode session response")
				completion(false, error)
			}
		}
		task.resume()
	}
    
}
