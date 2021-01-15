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
    
    func use(_ item: YTMessageWrapper.YTMessage) {
        message.text = item.message.first?.text ?? "MSGERR"
        author.text = item.author.name
//        datetime.text = item.snippet.publishedAt.value.toRelative(style: RelativeFormatter.twitterStyle(), locale: Locales.english)
    }
}
