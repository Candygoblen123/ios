//
//  ChatTextCell.swift
//  ios
//
//  Created by Mason Phillips on 1/22/21.
//

import UIKit
import Reusable

class ChatTextCell: UITableViewCell, NibReusable {

    static let identifier: String = "chatTextCell"
    
    @IBOutlet weak var message : UILabel!
    @IBOutlet weak var author  : UILabel!
    @IBOutlet weak var datetime: UILabel!
    
    let settings = AppSettings.shared
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func use(_ item: DisplayableMessage) {
        datetime.isHidden = !settings.timestamps
        
        author.text = item.displayAuthor
        datetime.text = item.displayTimestamp

        let fullMessage = NSMutableAttributedString()
        
        for m in item.displayMessage {
            switch m {
            case .text(let s):
                let am = NSAttributedString(string: s)
                fullMessage.append(am)
            case .emote(let u):
                let html = "<img src=\"\(u.absoluteString)\" />"
                let data = Data(html.utf8)
                
                let string = try! NSAttributedString(data: data, options: [
                    .documentType: NSAttributedString.DocumentType.html
                ], documentAttributes: nil)
                
                fullMessage.append(string)
            }
        }
        
        message.attributedText = fullMessage
    }
}
