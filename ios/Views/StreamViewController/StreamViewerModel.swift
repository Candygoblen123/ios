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
    
    let chatRelay = BehaviorRelay<[DisplayableMessage]>(value: [])
    let emptyTable = BehaviorRelay<Bool>(value: true)
    
    let chatControl = BehaviorRelay<Int>(value: 0)
    
    let liveChat = BehaviorRelay<[YTRawMessage]>(value: [])
    let translatedChat = BehaviorRelay<[DisplayableMessage]>(value: [])
    
    required init(_ stepper: Stepper, services: AppService) {
        super.init(stepper, services: services)

        let control = Observable.combineLatest(chatControl, liveChat, translatedChat) { (control, live, translated) in
            return control == 0 ? live : translated
        }
        
        control.bind(to: chatRelay).disposed(by: bag)
        control.map { $0.isEmpty }.bind(to: emptyTable).disposed(by: bag)
        
        emptyTable.filter { $0 }.subscribe(onNext: { [chatRelay] _ in chatRelay.accept([]) }).disposed(by: bag)
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
