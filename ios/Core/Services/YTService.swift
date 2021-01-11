//
//  YTService.swift
//  ios
//
//  Created by Mason Phillips on 1/11/21.
//

import Foundation
import KeychainAccess
import RxCocoa
import RxSwift

fileprivate typealias Keys = AuthService.Keys

struct YTService {
    private let keychain: Keychain
    private let baseURL : URL = URL(string: "https://youtube.googleapis.com/youtube/v3")!
    
    private var apiKey: String? {
        ProcessInfo.processInfo.environment["API_KEY"]
    }
    private var token: String? {
        keychain[Keys.token.rawValue]
    }
    
    enum APIError: Error {
        case unknownStatus(code: Int)
    }
    
    let yt_ChatPollInterval = BehaviorRelay<Int?>(value: nil)
    let yt_LiveChat         = BehaviorRelay<[Decodable]>(value: [])
    
    private let yt_NextToken = BehaviorRelay<String?>(value: nil)
    
    init() {
        keychain = Keychain(service: Keys.service.rawValue)
    }
    
    func fetchDetails(for id: String) -> Single<YTVideoRequest.Result> {
        return self._request(YTVideoRequest(id: id))
    }
    
    func beginChatRequest(liveId: String) {
        
    }
}

private extension YTService {
    func _build<T: APIRequest>(_ request: T) -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(request.endpoint), resolvingAgainstBaseURL: false)!
        
        var queryItems = request.params.map { URLQueryItem(name: $0.key, value: $0.value) }
        if apiKey != nil && token == nil {
            queryItems.append(URLQueryItem(name: "key", value: apiKey!))
        }
        components.queryItems = queryItems
        
        var urlRequest = URLRequest(url: components.url!)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
    
    func _request<T: APIRequest>(_ request: T) -> Single<T.Result> {
        let apiRequest = self._build(request)
        return Single<T.Result>.create { observer -> Disposable in
            let task = URLSession.shared.dataTask(with: apiRequest) { data, response, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode(T.Result.self, from: data)
                        observer(.success(json))
                    } catch {
                        observer(.failure(error))
                    }
                } else if let error = error {
                    observer(.failure(error))
                } else {
                    let response = response as? HTTPURLResponse
                    observer(.failure(APIError.unknownStatus(code: response?.statusCode ?? -1)))
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
}

protocol APIRequest {
    associatedtype Result: Decodable
    
    var endpoint: String { get }
    var params  : Dictionary<String, String> { get }
}
