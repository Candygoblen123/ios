//
//  StreamViewerController.swift
//  ios
//
//  Created by Mason Phillips on 1/7/21.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import Reusable
import youtube_ios_player_helper
import FLEX

class StreamViewerController: UIViewController, StoryboardBased, BaseController {
    var model: StreamViewerModel!
    
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var tableView: UITableView!
    
    var viewLoadedObservable = BehaviorRelay<Bool>(value: false)
    let bag = DisposeBag()

    var gesture: UITapGestureRecognizer {
        let g = UITapGestureRecognizer(target: self, action: #selector(showFlex))
        g.numberOfTouchesRequired = 2
        g.numberOfTapsRequired = 2
        return g
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(gesture)
        
        tableView.rx.setDelegate(model).disposed(by: bag)
        tableView.register(cellType: ChatCell.self)
        
        let dataSource = RxTableViewSectionedReloadDataSource<YTMessageSection>(configureCell: { source, table, index, item in
            let cell = table.dequeueReusableCell(for: index) as ChatCell
            cell.use(item)
            return cell
        })
        
        model.liveChat
            .filter { !$0.isEmpty }
            .map { $0.sorted { $0.snippet.publishedAt > $1.snippet.publishedAt }}
            .map { [YTMessageSection(items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        guard playerView != nil else { return }
        playerView.delegate = self
        viewLoadedObservable.accept(true)
    }
    
    func loadStreamWithId(id: String) {
        viewLoadedObservable.filter { $0 }.subscribe(onNext: { [weak self] _ in
            let vars = [
                "playsinline": true,
                "autoplay": true,
                "controls": false,
                "fs": false,
                "rel": false
            ]
            self?.playerView?.load(withVideoId: id, playerVars: vars)
            
            self?.model.loadFromAPI(id: id)
        }).disposed(by: bag)
    }
    
    @IBAction func playVideo() {
        playerView.playVideo()
    }
    @IBAction func pauseVideo() {
        playerView.pauseVideo()
    }
    
    @objc func showFlex() {
        FLEXManager.shared.showExplorer()
    }
}

extension StreamViewerController: YTPlayerViewDelegate {
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        print(state)
    }
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        
    }
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        
    }
}

struct YTMessageSection: SectionModelType {
    typealias Item = YTMessageResponse.MessageItem
    var items: [Item]
    
    init(original: Self, items: [Item]) {
        self = original
        self.items = items
    }
    init(items: [Item]) {
        self.items = items
    }
}
