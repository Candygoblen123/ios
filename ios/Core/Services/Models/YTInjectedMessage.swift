//
//  YTInjectedMessage.swift
//  ios
//
//  Created by Mason Phillips on 1/21/21.
//

import Foundation
import SwiftDate
import RxDataSources

typealias LangToken = (start: Character, end: Character)
let tokens: [LangToken] = [
    (start: "[", end: "]"),
    (start: "{", end: "}"),
    (start: "(", end: ")"),
    (start: "|", end: "|"),
    (start: "<", end: ">"),
    (start: "【", end: "】"),
    (start: "「", end: "」"),
    (start: "『", end: "』"),
    (start: "〚", end: "〛"),
    (start: "（", end: "）"),
    (start: "〈", end: "〉"),
    (start: "⁽", end: "₎")
]

protocol DisplayableMessage {
    var displayAuthor   : String    { get }
    var displayTimestamp: String    { get }
    
    var displayMessage  : [Message] { get }
    
    var sortTimestamp   : Date      { get }
}
extension DisplayableMessage {
    static func >(l: Self, r: Self) -> Bool {
        return l.sortTimestamp > r.sortTimestamp
    }
    static func <(l: Self, r: Self) -> Bool {
        return l.sortTimestamp < r.sortTimestamp
    }
}

enum Message: Decodable {
    case text(_ str: String)
    case emote(_ url: URL)
    
    enum CodingKeys: String, CodingKey {
        case type
        case src, text
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let msgType = try container.decode(String.self, forKey: .type)
        
        if msgType == "emote" {
            let url = try container.decode(URL.self, forKey: .src)
            self = .emote(url)
        } else if msgType == "text" {
            let str = try container.decode(String.self, forKey: .text)
            self = .text(str)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type],
                                                                    debugDescription: "Could not find a supported type for the content provided"))
        }
    }
}


struct YTInjectedMessageChunk: Decodable {
    let type    : String
    let messages: [YTRawMessage]
    let isReplay: Bool
}

struct YTTranslatedMessage {
    let author   : Author
    let message  : String!
    let language : String!
    let timestamp: Date
    
    var langTag: TranslatedLanguageTag? {
        return TranslatedLanguageTag(language.lowercased())
    }
    
    init?(from message: YTRawMessage) {
        author = Author(from: message.author)
        timestamp = message.timestamp
        
        var m: String? = nil
        var l: String? = nil
        
        if case let .text(s) = message.messages.first {
            for token in tokens {
                guard
                    let beginToken = s.firstIndex(of: token.start),
                    let endToken = s.firstIndex(of: token.end)
                else { continue }
                
                guard beginToken < endToken else { continue }
                
                let lang = String(s[beginToken..<endToken])
                    .replacingOccurrences(of: "\(token.start)", with: "")
                    .replacingOccurrences(of: "\(token.end)", with: "")
                    .replacingOccurrences(of: " ", with: "")
                    .lowercased()
                
                let validTags = TranslatedLanguageTag.allCases.map { $0.tag }
                guard validTags.contains(lang.lowercased()) else { continue }
                
                let msgStart = s.index(after: endToken)
                let msg = String(s[msgStart..<s.endIndex])
                
                l = lang
                m = msg
                
                break
            }
        }
        
        if let l = l, let m = m {
            self.language = l
            self.message = m
        } else { return nil }
    }
    
    struct Author {
        let name : String
        let types: [String]
        
        init(from author: YTRawMessage.Author) {
            name = author.name
            types = author.types
        }
    }
}

struct YTRawMessage: Decodable {
    let author: Author
    let messages: [Message]
    let timestamp: Date
    let showtime: Float?
    
    struct Author: Decodable {
        let name : String
        let id   : String
        let types: [String]
    }
}
extension YTRawMessage: DisplayableMessage {
    var displayAuthor: String {
        return author.name
    }
    var displayMessage: [Message] {
        return messages
    }
    var displayTimestamp: String {
        return timestamp.toRelative(style: RelativeFormatter.twitterStyle(), locale: Locales.english)
    }
    
    static func >(l: Self, r: Self) -> Bool {
        return l.timestamp > r.timestamp
    }
    static func <(l: Self, r: Self) -> Bool {
        return l.timestamp < r.timestamp
    }
    var sortTimestamp: Date {
        return timestamp
    }
}

extension YTTranslatedMessage: DisplayableMessage {
    var displayAuthor: String {
        return author.name
    }
    var displayMessage: [Message] {
        return [.text(self.message)]
    }
    var displayTimestamp: String {
        return timestamp.toRelative(style: RelativeFormatter.twitterStyle(), locale: Locales.english)
    }
    var sortTimestamp: Date {
        return timestamp
    }
}
