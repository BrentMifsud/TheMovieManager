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
		case deleteSession

		var stringValue: String {
			switch self {
			case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
			case .getRequestToken: return Endpoints.base + "/authentication/token/new" + Endpoints.apiKeyParam
			case .login: return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
			case .getSessionId: return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
			case .webAuth: return "https://www.themoviedb.org/authenticate/\(Auth.requestToken)?redirect_to=themoviemanager:authenticate"
			case .deleteSession: return Endpoints.base + "/authentication/session" + Endpoints.apiKeyParam
			}
		}

		var url: URL {
			return URL(string: stringValue)!
		}
	}

	class func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
		let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard let data = data else {
				DispatchQueue.main.async {
					completion(nil, error)
				}
				return
			}

			do {
				let responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
				DispatchQueue.main.async {
					completion(responseObject, nil)
				}
			} catch {
				DispatchQueue.main.async {
					completion(nil, error)
				}

			}
		}
		task.resume()

	}

	class func taskForPostRequest<RequestType: Codable, ResponseType: Decodable>(url: URL, body: RequestType, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try! JSONEncoder().encode(body)

		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let data = data else {
				DispatchQueue.main.async {
					completion(nil, error)
				}
				return
			}

			do {
				let responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
				DispatchQueue.main.async {
					completion(responseObject, nil)
				}
			} catch {
				DispatchQueue.main.async {
					completion(nil, error)
				}
			}
		}
		task.resume()
	}

	class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
		taskForGetRequest(url: Endpoints.getWatchlist.url, responseType: MovieResults.self) { (response, error) in
			if let response = response {
				completion(response.results, nil)
			} else {
				completion([], error)
			}
		}
	}


	class func getRequestToken(completion: @escaping (Bool, Error?) -> Void) {
		taskForGetRequest(url: Endpoints.getRequestToken.url, responseType: RequestTokenResponse.self) { (response, error) in
			if let response = response {
				Auth.requestToken = response.requestToken
				completion(true, nil)
			} else {
				completion(false, error)
			}
		}
	}

	class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void){
		let body = LoginRequest(username: username, password: password, requestToken: Auth.requestToken)
		taskForPostRequest(url: Endpoints.login.url, body: body, responseType: RequestTokenResponse.self) { (response, error) in
			if let response = response {
				Auth.requestToken = response.requestToken
				completion(true, nil)
			} else {
				completion(false, nil)
			}
		}
	}

	class func	getSessionId(completion: @escaping (Bool, Error?) -> Void){
		let body = PostSession(requestToken: Auth.requestToken)
		taskForPostRequest(url: Endpoints.getSessionId.url, body: body, responseType: SessionResponse.self) { (response, error) in
			if let response = response {
				Auth.sessionId = response.sessionId
				completion(true, nil)
			} else {
				completion(false, error)
			}
		}
	}

	class func logout(completion: @escaping (Bool, Error?) -> Void){
		let body = LogoutRequest(sessionId: Auth.sessionId)
		var request = URLRequest(url: Endpoints.deleteSession.url)
		request.httpMethod = "DELETE"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try! JSONEncoder().encode(body)

		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			Auth.requestToken = ""
			Auth.sessionId = ""
			completion(true, nil)
		}
		task.resume()
	}

}
