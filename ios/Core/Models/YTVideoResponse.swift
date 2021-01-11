//
//  YTVideoResponse.swift
//  ios
//
//  Created by Mason Phillips on 1/11/21.
//

import Foundation

struct YTVideoRequest: APIRequest {
    typealias Result = YTVideoResponse
    
    var endpoint: String { "/videos" }
    var params: Dictionary<String, String> {
        [
            "part": "liveStreamingDetails,snippet",
            "maxResults": "1",
            "id": "\(self.id)"
        ]
    }
    
    let id: String
}


struct YTVideoResponse: Decodable {
    let items: [VideoItem]
    
    struct VideoItem: Decodable {
        let id: String
        
        let snippet: VideoSnippet?
        let liveStreamingDetails: LiveStreamDetails?
        
        struct VideoSnippet: Decodable {
            let publishedAt: YTDecodableDateTime?
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
        let actualStartTime: YTDecodableDateTime?
        let scheduledStartTime: YTDecodableDateTime?
        let concurrentViewers: String?
        let activeLiveChatId: String?
    }
}
