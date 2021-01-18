//
//  ChatCell.swift
//  ios
//
//  Created by Mason Phillips on 1/7/21.
//

import UIKit
import SwiftDate
import Reusable

class ChatCell: UITableViewCell, NibReusable {
    static let identifier: String = "chatCell"
    
    @IBOutlet weak var message : UILabel!
    @IBOutlet weak var author  : UILabel!
    @IBOutlet weak var datetime: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func use<T: DisplayableMessage>(_ item: T) {
        guard let message = item.initialMessage else { return }
        switch message {
        case .text(let s): self.message.text = s
        default: break
        }
        author.text = item.author.name
        datetime.text = item.timestamp.toRelative(style: RelativeFormatter.twitterStyle(), locale: Locales.english)
    }
}
