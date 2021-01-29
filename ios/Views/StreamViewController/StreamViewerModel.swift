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
import WebKit

class StreamViewerModel: BaseModel {
    
    let chatRelay  = BehaviorRelay<[DisplayableMessage]>(value: [])
    let emptyTable = BehaviorRelay<Bool>(value: true)
    
    let chatControl = BehaviorRelay<Int>(value: 0)
    
    let chatUrl       = BehaviorRelay<URL?>(value: nil)
    let replayControl = BehaviorRelay<Bool?>(value: nil)
    
    private let liveChat       = BehaviorRelay<[YTRawMessage]>(value: [])
    private let translatedChat = BehaviorRelay<[DisplayableMessage]>(value: [])
    
    required init(_ stepper: Stepper, services: AppService) {
        super.init(stepper, services: services)

        let control = Observable.combineLatest(chatControl, liveChat, translatedChat) { (control, live, translated) in
            return control == 0 ? live : translated
        }
        
        control.bind(to: chatRelay).disposed(by: bag)
        control.map { $0.isEmpty }.bind(to: emptyTable).disposed(by: bag)
        
        emptyTable.filter { $0 }.subscribe(onNext: { [chatRelay] _ in chatRelay.accept([]) }).disposed(by: bag)
    }
    
    func performChatLoad(_ id: String) {
        let pattern = """
        continuation":"(\\w+)"
        """

        var chatUrlFinal = "https://www.youtube.com/live_chat"
        
        var request = URLRequest(url: URL(string: "https://www.youtube.com/watch?v=\(id)")!)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1.2 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data, let html = String(data: data, encoding: .utf8) {
                if let token = html.groups(for: pattern).first?.last {
                    // is replay stream
                    chatUrlFinal.append("_replay?v=\(id)&continuation=\(token)&embed_domain=www.livetl.app&app=desktop")
                    self.replayControl.accept(true)
                } else {
                    chatUrlFinal.append("?v=\(id)&embed_domain=www.livetl.app&app=desktop")
                    self.replayControl.accept(false)
                }
                
                self.chatUrl.accept(URL(string: chatUrlFinal))
            }
        }.resume()
        
//        chatUrl.compactMap { $0 }.subscribe(onNext: { print($0.absoluteString) }).disposed(by: bag)
    }
}

extension StreamViewerModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
            let items = try decoder.decode(YTInjectedMessageChunk.self, from: data)
            
            var full = liveChat.value
            full.append(contentsOf: items.messages)
            liveChat.accept(full)
            
            var translated = translatedChat.value
            let mapTranslated = items.messages.compactMap { YTTranslatedMessage(from: $0) }
            translated.append(contentsOf: mapTranslated)
            translatedChat.accept(translated)
        } catch {
            print(error)
        }
    }
}

enum YTMessageError: Error {
    case missingStrDataConversion
}

extension String {
    func groups(for regexPattern: String) -> [[String]] {
        do {
            let text = self
            let regex = try NSRegularExpression(pattern: regexPattern)
            let matches = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
            return matches.map { match in
                return (0..<match.numberOfRanges).map {
                    let rangeBounds = match.range(at: $0)
                    guard let range = Range(rangeBounds, in: text) else {
                        return ""
                    }
                    return String(text[range])
                }
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
