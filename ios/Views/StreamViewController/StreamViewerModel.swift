//
//  StreamViewerModel.swift
//  ios
//
//  Created by Mason Phillips on 1/7/21.
//

import Foundation
import RxCocoa
import RxFlow
import RxSwift
import SwiftDate
import KeychainAccess

class StreamViewerModel: BaseModel {
    var apiKey: String {
        guard let k = ProcessInfo.processInfo.environment["API_KEY"] else { fatalError("API Key not supplied") }
        return k
    }
    var accessToken: String? {
        return Keychain(service: "app.livetl.ios")[AuthService.Keys.token.rawValue]
    }
    
    var gidToken = BehaviorRelay<String?>(value: nil)
    
    let liveChatId = BehaviorRelay<String?>(value: nil)
    let liveChat = BehaviorRelay<[YTMessageResponse.MessageItem]>(value: [])
    
    let pollingInterval = BehaviorRelay<Int>(value: -1)
    let nextPageToken   = BehaviorRelay<String>(value: "")
    
    required init(_ stepper: Stepper, services: AppService) {
        super.init(stepper, services: services)

        liveChatId.compactMap { $0 }.subscribe(onNext: { chat in
            print(chat)
            self.getChatMessages(liveId: chat)
        }, onError: { e in
            print(e)
        }).disposed(by: bag)
    }
    
    func loadFromAPI(id: String) {
//        let urlString = "https://youtube.googleapis.com/youtube/v3/videos?part=liveStreamingDetails&part=snippet&id=\(id)&maxResults=1"

        services.yt.fetchDetails(for: id)
            .map { $0.items.first }
            .filter { $0?.snippet?.liveBroadcastContent != Optional.none }
            .map { $0?.liveStreamingDetails?.activeLiveChatId }
            .asObservable()
            .bind(to: liveChatId)
            .disposed(by: bag)
    }
    
    func getChatMessages(liveId: String) {
        let obs = Observable.combineLatest(pollingInterval, nextPageToken)
            .flatMapLatest { (p, t) -> Observable<YTMessageResponse> in
                if p < 0 && t.isEmpty {
                    let urlString = "https://youtube.googleapis.com/youtube/v3/liveChat/messages?liveChatId=\(liveId)&part=snippet&part=authorDetails"
                    return self.request(URL(string: urlString)!, type: YTMessageResponse.self).asObservable()
                } else {
                    let urlString = "https://youtube.googleapis.com/youtube/v3/liveChat/messages?liveChatId=\(liveId)&part=snippet&part=authorDetails&nextPageToken=\(t)"
                    return Observable<Int>.timer(.milliseconds(p), scheduler: MainScheduler.asyncInstance).flatMapLatest { _ in
                        return self.request(URL(string: urlString)!, type: YTMessageResponse.self).asObservable()
                    }.take(1)
                }
            }
        
        obs.compactMap { $0.pollingIntervalMillis }
            .bind(to: pollingInterval)
            .disposed(by: bag)
        obs.compactMap { $0.nextPageToken }
            .bind(to: nextPageToken)
            .disposed(by: bag)
        obs.compactMap { $0.items }
            .bind(to: liveChat)
            .disposed(by: bag)        
    }
    
    private func request<T: Decodable>(_ url: URL, type: T.Type) -> Single<T> {
        let final: URL
        if(self.accessToken == nil) {
            final = url.appendingPathComponent("&key=\(self.apiKey)")
        } else { final = url }
        
        var request = URLRequest(url: final)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return Single<T>.create { subscriber -> Disposable in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode(T.self, from: data)
                        subscriber(.success(json))
                    } catch {
                        subscriber(.failure(error))
                    }
                } else if let error = error {
                    subscriber(.failure(error))
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

extension StreamViewerModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
