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
import WebKit

class StreamViewerModel: BaseModel {
    
    let chatRelay = PublishRelay<[DisplayableMessage]>()
    
    let chatControl = BehaviorRelay<Int>(value: 0)
    
    let liveChat = BehaviorRelay<[DisplayableMessage]>(value: [])
    let translatedChat = BehaviorRelay<[DisplayableMessage]>(value: [])
    
    required init(_ stepper: Stepper, services: AppService) {
        super.init(stepper, services: services)
        
        Observable.combineLatest(chatControl, liveChat, translatedChat) { (control, live, translated) in
            return control == 0 ? live : translated
        }.bind(to: chatRelay).disposed(by: bag)
    }
}

extension StreamViewerModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension StreamViewerModel: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? String else { print("could not get message as string"); return }
        
        let data = body.data(using: .utf8)
        do {
            guard let data = data else { throw YTMessageError.missingStrDataConversion }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            let items = try decoder.decode(YTMessageWrapper.self, from: data)
            
            var full = liveChat.value
            full.append(contentsOf: items.messages)
            liveChat.accept(full)
            
            let translated = full.compactMap { ($0 as? YTMessageWrapper.YTMessage)?.translatedMessage }
            translatedChat.accept(translated)
        } catch {
            print(error)
        }
    }
}

enum YTMessageError: Error {
    case missingStrDataConversion
}

struct YTTranslatedWrapper: DisplayableMessage {
    let translation: TransLang
    
    let author        : YTMessageWrapper.YTMessage.Author
    let initialMessage: YTMessageWrapper.YTMessage.Message?
    let timestamp     : Date
    
    init?(_ message: YTMessageWrapper.YTMessage) {
        guard let msg = message.message.first else { return nil }
        
        let tagRegex = try! NSRegularExpression(pattern: "^\\[[a-zA-Z]\\]", options: .anchorsMatchLines)
        
        if case let .text(s) = msg, tagRegex.numberOfMatches(in: s, options: .anchored, range: NSRange(location: 0, length: s.count)) > 0 {
            
            self.translation = .en
            
            self.author = message.author
            self.initialMessage = msg
            self.timestamp = message.timestamp
        } else { return nil }
    }
    
    enum TransLang: String {
        case en, jp, sp, id, kr, cn, ra, fr
        case dev
    }
}

protocol DisplayableMessage {
    var initialMessage: YTMessageWrapper.YTMessage.Message? { get }
    var author        : YTMessageWrapper.YTMessage.Author { get }
    var timestamp     : Date { get }
}

struct YTMessageWrapper: Decodable {
    let type: String
    let messages: [YTMessage]
    let isReplay: Bool
        
    struct YTMessage: Decodable, DisplayableMessage {
        let author: Author
        let message: [Message]
        let timestamp: Date
        let showtime: Int
        
        var initialMessage: Message? {
            return message.first
        }
        
        var translatedMessage: YTTranslatedWrapper? {
            return YTTranslatedWrapper(self)
        }
                
        struct Author: Decodable {
            let name: String
            let id: String
            let types: [String]
            
            enum AuthorType: String, Decodable {
                case moderator = "Moderator"
                case verified = "Verified"
                case distinguished = "Distinguished"
                case standard = "Standard"
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
    }
}
