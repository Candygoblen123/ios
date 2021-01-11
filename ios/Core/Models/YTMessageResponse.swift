//
//  YTMessageResponse.swift
//  ios
//
//  Created by Mason Phillips on 1/11/21.
//

import Foundation

struct YTMessageRequest: APIRequest {
    typealias Result = YTMessageResponse
    
    var endpoint: String { "" }
    var params: Dictionary<String, String> { [:] }
    
    let chatId: String
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
            let publishedAt: YTDecodableDateTime
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
