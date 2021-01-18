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
import SwiftDate

class StreamViewerController: UIViewController, StoryboardBased, BaseController {
    var model: StreamViewerModel!
    
    @IBOutlet weak var playerView  : YTPlayerView!
    @IBOutlet weak var tableView   : UITableView!
    @IBOutlet weak var chatControl : UISegmentedControl!
    @IBOutlet weak var nextRefresh : UIProgressView!
    @IBOutlet weak var injectorView: WKWebView!
    
//    let injectorView: WKWebView = WKWebView(frame: .zero)
    
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
        
        chatControl.rx.value.bind(to: model.chatControl).disposed(by: bag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<YTMessageSection>(configureCell: { source, table, index, item in
            let cell = table.dequeueReusableCell(for: index) as ChatCell
            
            guard let message = item.initialMessage else { return cell }
            switch message {
            case .text(let s): cell.message.text = s
            default: break
            }
            cell.author.text = item.author.name
            cell.datetime.text = item.timestamp.toRelative(style: RelativeFormatter.twitterStyle(), locale: Locales.english)
            
            return cell
        })
        
        model.chatRelay
            .filter { !$0.isEmpty }
            .map { $0.sorted { $0.timestamp > $1.timestamp }}
            .map { [YTMessageSection(items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        guard playerView != nil else { return }
        playerView.delegate = self
        viewLoadedObservable.accept(true)
        
        do {
            let path = Bundle.main.path(forResource: "WindowInjector", ofType: "js") ?? ""
            let js = try String(contentsOfFile: path, encoding: .utf8)
            let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            
            injectorView.configuration.userContentController.addUserScript(script)
            injectorView.configuration.userContentController.add(self.model, name: "ios_messageReceive")
        } catch {
            print(error)
        }
    }
    
    func loadStreamWithId(id: String) {
        viewLoadedObservable.filter { $0 }.subscribe(onNext: { [weak self] _ in
            let _ = [
                "playsinline": true,
                "autoplay": true,
                "controls": false,
                "fs": false,
                "rel": false
            ]
            self?.playerView?.load(withVideoId: id, playerVars: [:])
            
            let request = URLRequest(url: URL(string: "https://www.youtube.com/live_chat?v=\(id)&embed_domain=www.livetl.app&app=desktop")!)
            self?.injectorView.load(request)
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
    typealias Item = DisplayableMessage
    var items: [Item]
    
    init(original: Self, items: [Item]) {
        self = original
        self.items = items
    }
    init(items: [Item]) {
        self.items = items
    }
}
