//
//  StreamCell.swift
//  ios
//
//  Created by Mason Phillips on 2/2/21.
//

import UIKit
import Neon
import RxCocoa
import RxSwift
import Kingfisher
import SwiftDate

class StreamCell: UITableViewCell {
    static let identifier: String = "liveStreamCell"

    var item: YTStreamers.Streamer!
    
    let iconView = UIImageView()
    
    let titleLabel   = UILabel()
    let channelLabel = UILabel()
    let timeLabel    = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(iconView)
        
        titleLabel.font = .systemFont(ofSize: 18)
        titleLabel.textColor = .label
        contentView.addSubview(titleLabel)
        
        channelLabel.font = .systemFont(ofSize: 14)
        channelLabel.textColor = .secondaryLabel
        contentView.addSubview(channelLabel)
        
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .secondaryLabel
        timeLabel.textAlignment = .right
        contentView.addSubview(timeLabel)
    }
    
    func configure(with item: YTStreamers.Streamer) {
        self.item = item
        
        iconView.kf.setImage(with: item.channel.photo)
        
        titleLabel.text = item.title
        channelLabel.text = item.channel.name
        timeLabel.text = item.live_schedule.toRelative(style: RelativeFormatter.twitterStyle(), locale: Locales.english)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconView.anchorToEdge(.left, padding: 10, width: 40, height: 40)
        iconView.layer.cornerRadius = iconView.height / 2
        iconView.clipsToBounds = true
        
        titleLabel.alignAndFillWidth(align: .toTheRightMatchingTop, relativeTo: iconView, padding: 5, height: 20)
        channelLabel.align(.toTheRightMatchingBottom, relativeTo: iconView, padding: 5, width: width - 145, height: 18)
        timeLabel.anchorInCorner(.bottomRight, xPad: 10, yPad: 15, width: 100, height: 18)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
