//
//  APIServices.swift
//  ios
//
//  Created by Mason Phillips on 2/2/21.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources
import XCDYouTubeKit

class YTAPIServices {
    
    init() {}
    
    func getLiveStreamers() -> Single<YTStreamers> {
        return Single.create { observer in
            let url = URL(string: "https://jetrico.sfo2.digitaloceanspaces.com/hololive/youtube.json")!
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601WithMilli
                        let json = try decoder.decode(YTStreamers.self, from: data)
                        observer(.success(json))
                    } catch {
                        observer(.failure(error))
                    }
                } else {
                    observer(.failure(error!))
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func getYTPlayer(for id: String) -> Single<XCDYouTubeVideo> {
        return Single<XCDYouTubeVideo>.create { observer -> Disposable in
            XCDYouTubeClient.default().getVideoWithIdentifier(id) { (video, error) in
                guard error == nil, let video = video else { observer(.failure(error!)); return }
                observer(.success(video))
            }
            
            return Disposables.create()
        }
    }
    
    func getYTDetails(for id: String) -> Single<YTVideoInfo> {
        return Single.create { observer in
            let request = URLRequest(url: URL(string: "https://www.youtube.com/oembed?url=http://www.youtube.com/watch?v=\(id)&format=json")!)
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode(YTVideoInfo.self, from: data)
                        observer(.success(json))
                    } catch {
                        observer(.failure(error))
                    }
                } else {
                    observer(.failure(error!))
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

struct YTVideoInfo: Decodable {
    let title: String
    let author_name: String
    let author_url: String
    let thumbnail_url: URL    
}

struct YTStreamers: Decodable {
    let live: [Streamer]
    let upcoming: [Streamer]
    let ended: [Streamer]
    let cached: Bool
    
    struct Streamer: Decodable {
        let id: Int
        let yt_video_key: String?
        let bb_video_id: String?
        let title: String
        let thumbnail: String?
        let status: VideoStatus
        let live_schedule: Date
        let live_start: Date?
        let live_end: Date?
        let live_viewers: Int?
        let channel: Channel
        
        enum VideoStatus: String, Decodable {
            case past, live, upcoming
        }
        
        struct Channel: Decodable {
            let id: Int
            let yt_channel_id: String?
            let bb_space_id: String?
            let name: String
            let photo: URL
            let published_at: Date
            let twitter_link: String
            let view_count: Int
            let subscriber_count: Int
            let video_count: Int
        }
    }
    
    func sections() -> [StreamersModel] {
        return [
            StreamersModel(self.live, title: "Live"),
            StreamersModel(self.upcoming, title: "Upcoming"),
            StreamersModel(self.ended, title: "Ended")
        ]
    }
    
    static var `default`: YTStreamers {
        return YTStreamers(live: [], upcoming: [], ended: [], cached: false)
    }
}

extension JSONDecoder.DateDecodingStrategy {
    static var iso8601WithMilli: Self {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        return .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)

            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "No valid date format")
        })
    }
}
