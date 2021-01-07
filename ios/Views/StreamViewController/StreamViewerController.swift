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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "chatCell")
        
        model.liveChat
            .filter { !$0.isEmpty }
            .bind(to: tableView.rx.items(cellIdentifier: "chatCell", cellType: UITableViewCell.self)) { index, item, cell in
                cell.textLabel?.text = item.snippet.displayMessage
            }.disposed(by: bag)
        
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
