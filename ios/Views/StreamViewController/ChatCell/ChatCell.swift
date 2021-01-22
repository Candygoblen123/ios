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
    
    func use(_ item: DisplayableMessage) {
        message.text = item.displayMessage
        author.text = item.displayAuthor
        datetime.text = item.displayTimestamp
    }
}
