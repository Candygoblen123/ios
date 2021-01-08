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

class StreamViewerModel: BaseModel {
    var apiKey: String {
        guard let k = ProcessInfo.processInfo.environment["API_KEY"] else { fatalError("API Key not supplied") }
        return k
    }
    
    let liveChatId = BehaviorRelay<String?>(value: nil)
    let liveChat = BehaviorRelay<[YTMessageResponse.MessageItem]>(value: [])
    
    let pollingInterval = BehaviorRelay<Int>(value: -1)
    let nextPageToken   = BehaviorRelay<String>(value: "")
    
    required init(_ stepper: Stepper) {
        super.init(stepper)
        
        liveChatId.compactMap { $0 }.subscribe(onNext: { chat in
            print(chat)
            self.getChatMessages(liveId: chat)
        }, onError: { e in
            print(e)
        }).disposed(by: bag)
    }
    
    func loadFromAPI(id: String) {
        let urlString = "https://youtube.googleapis.com/youtube/v3/videos?part=liveStreamingDetails&part=snippet&id=\(id)&maxResults=1&key=\(apiKey)"
        let url = URL(string: urlString)!
        self.request(url, type: YTVideoResponse.self, token: nil)
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
                    let urlString = "https://youtube.googleapis.com/youtube/v3/liveChat/messages?liveChatId=\(liveId)&part=snippet&part=authorDetails&key=\(self.apiKey)"
                    return self.request(URL(string: urlString)!, type: YTMessageResponse.self, token: nil).asObservable()
                } else {
                    let urlString = "https://youtube.googleapis.com/youtube/v3/liveChat/messages?liveChatId=\(liveId)&part=snippet&part=authorDetails&key=\(self.apiKey)&nextPageToken=\(t)"
                    return Observable<Int>.timer(.milliseconds(p), scheduler: MainScheduler.asyncInstance).flatMapLatest { _ in
                        return self.request(URL(string: urlString)!, type: YTMessageResponse.self, token: nil).asObservable()
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
    
    private func request<T: Decodable>(_ url: URL, type: T.Type, token: String?) -> Single<T> {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return Single<T>.create { subscriber -> Disposable in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
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

struct DecodableYTDateTime: Decodable, Equatable {
    let value: Date
    
    init(from decoder: Decoder) throws {
        let context = try decoder.singleValueContainer()
        let str = try context.decode(String.self)
        guard let value = str.toDate()?.date else {
            throw DecodingError.dataCorruptedError(in: context, debugDescription: "Expected to decode Date but found unexpected string")
        }
        self.value = value
    }
    
    static func >(l: Self, r: Self) -> Bool {
        return l.value > r.value
    }
    static func <(l: Self, r: Self) -> Bool {
        return l.value < r.value
    }
    static func ==(l: Self, r: Self) -> Bool {
        return l.value == r.value
    }
}

struct YTVideoResponse: Decodable {
    let items: [VideoItem]
    
    struct VideoItem: Decodable {
        let id: String
        
        let snippet: VideoSnippet?
        let liveStreamingDetails: LiveStreamDetails?
        
        struct VideoSnippet: Decodable {
            let publishedAt: DecodableYTDateTime?
            let channelId: String?
            let title: String?
            let description: String?
            let channelTitle: String?
            let liveBroadcastContent: LiveContent?

            enum LiveContent: String, Decodable {
                case live, none, upcoming
            }
        }
    }
    
    struct LiveStreamDetails: Decodable {
        let actualStartTime: DecodableYTDateTime?
        let scheduledStartTime: DecodableYTDateTime?
        let concurrentViewers: String?
        let activeLiveChatId: String?
    }
}

struct YTMessageResponse: Decodable {
    let pollingIntervalMillis: Int
    let nextPageToken: String?
    let items: [MessageItem]
    
    struct MessageItem: Decodable {
        let id: String
        let snippet: MessageSnippet
        let authorDetails: Author
        
        struct MessageSnippet: Decodable {
            let type: String
            let liveChatId: String
            let authorChannelId: String
            let publishedAt: DecodableYTDateTime
            let hasDisplayContent: Bool
            let displayMessage: String
            let textMessageDetails: MessageDetails?
            
            struct MessageDetails: Decodable {
                let messageText: String
            }
        }
        
        struct Author: Decodable {
            let channelId: String
            let channelUrl: String
            let displayName: String
            let profileImageUrl: String
            let isVerified: Bool
            let isChatOwner: Bool
            let isChatSponsor: Bool
            let isChatModerator: Bool
        }
    }
}
