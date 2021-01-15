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
    let liveChat = BehaviorRelay<[YTMessageWrapper.YTMessage]>(value: [])
    
    required init(_ stepper: Stepper, services: AppService) {
        super.init(stepper, services: services)
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
            let items = try JSONDecoder().decode(YTMessageWrapper.self, from: data)
            
            liveChat.accept(items.messages)
        } catch {
            print(error)
        }
    }
    
}

enum YTMessageError: Error {
    case missingStrDataConversion
}

struct YTMessageWrapper: Decodable {
    let type: String
    let messages: [YTMessage]
    let isReplay: Bool
    
    struct YTMessage: Decodable {
        let author: Author
        let message: [Message]
        let timestamp: String
        let showtime: Int
        
        struct Author: Decodable {
            let name: String
            let id: String
            let types: [AuthorType]
            
            enum AuthorType: String, Decodable {
                case moderator = "Moderator"
                case verified = "Verified"
                case distinguished = "Distinguished"
                case standard = "Standard"
            }
        }
        
        struct Message: Decodable {
            let type: String
            let text: String
        }
    }
}
