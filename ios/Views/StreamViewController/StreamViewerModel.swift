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

class StreamViewerModel: BaseModel {
    var apiKey: String {
        guard let k = ProcessInfo.processInfo.environment["API_KEY"] else { fatalError("API Key not supplied") }
        return k
    }
    
    let liveChatId = BehaviorRelay<String?>(value: nil)
    let liveChat = BehaviorRelay<[YTMessageResponse.MessageItem]>(value: [])
    
    required init(_ stepper: Stepper) {
        super.init(stepper)
        
        liveChatId.compactMap { $0 }.subscribe(onNext: { chat in
            print(chat)
            self.getChatMessages(liveId: chat, nextToken: nil)
        }, onError: { e in
            print(e)
        }).disposed(by: bag)
    }
    
    func loadFromAPI(id: String) {
        let urlString = "https://youtube.googleapis.com/youtube/v3/videos?part=liveStreamingDetails&part=snippet&id=\(id)&maxResults=1&key=\(apiKey)"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        Single<YTVideoResponse?>.create { subscriber -> Disposable in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode(YTVideoResponse.self, from: data)
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
            .map { $0?.items.first }
            .filter { $0?.snippet?.liveBroadcastContent != Optional.none }
            .map { $0?.liveStreamingDetails?.activeLiveChatId }
            .asObservable()
            .bind(to: liveChatId)
            .disposed(by: bag)
    }
    
    func getChatMessages(liveId: String, nextToken: String?) {
        let urlString = "https://youtube.googleapis.com/youtube/v3/liveChat/messages?liveChatId=\(liveId)&part=snippet&part=authorDetails&key=\(apiKey)"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        Single<YTMessageResponse?>.create { subscriber -> Disposable in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode(YTMessageResponse.self, from: data)
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
        .compactMap { $0?.items }
        .asObservable()
        .bind(to: liveChat)
        .disposed(by: bag)
    }
}

extension StreamViewerModel: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        
        return cell
    }
}

struct YTVideoResponse: Decodable {
    let items: [VideoItem]
    
    struct VideoItem: Decodable {
        let id: String
        
        let snippet: VideoSnippet?
        let liveStreamingDetails: LiveStreamDetails?
        
        struct VideoSnippet: Decodable {
            let publishedAt: String?
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
        let actualStartTime: String?
        let scheduledStartTime: String?
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
            let publishedAt: String
            let hasDisplayContent: Bool
            let displayMessage: String
            let textMessageDetails: MessageDetails
            
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
