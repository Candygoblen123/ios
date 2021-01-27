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
import SwiftDate
import WebKit
import XCDYouTubeKit
import AVKit

#if canImport(FLEX)
    import FLEX
#endif

class StreamViewerController: UIViewController, StoryboardBased, BaseController {
    var model: StreamViewerModel!
    
    @IBOutlet weak var videoView   : UIView!
    @IBOutlet weak var tableView   : UITableView!
    @IBOutlet weak var chatControl : UISegmentedControl!
    @IBOutlet weak var injectorView: WKWebView!
    
    @IBOutlet weak var controlButton: UIButton!
    
    var videoController: AVPlayerViewController!
    
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        
        tableView.rx.setDelegate(model).disposed(by: bag)
        tableView.register(cellType: ChatTextCell.self)
        model.emptyTable.subscribe(onNext: { [weak tableView] empty in
            if empty {
                tableView?.setEmptyMessage("No messages to display")
            } else { tableView?.restore() }
        }).disposed(by: bag)
        
        chatControl.rx.value.bind(to: model.chatControl).disposed(by: bag)

        let dataSource = RxTableViewSectionedReloadDataSource<YTMessageSection>(configureCell: { source, table, index, item in
            let cell = table.dequeueReusableCell(for: index) as ChatTextCell
            cell.use(item)
            return cell
        })
        
        model.chatRelay
            .map { $0.sorted { $0.sortTimestamp > $1.sortTimestamp }}
            .asDriver(onErrorJustReturn: [])
            .map { [YTMessageSection(items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
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
            XCDYouTubeClient.default().getVideoWithIdentifier(id) { (video, error) in
                guard error == nil else { print(error!); return }
                
                if let video = video, let url = video.streamURL {
                    let player = AVPlayer(url: url)
                    
                    self?.handleUpdateVideoController(player)
                } else { print("cant get video") }
            }
            
            let request = URLRequest(url: URL(string: "https://www.youtube.com/live_chat?v=\(id)&embed_domain=www.livetl.app&app=desktop")!)
            self?.injectorView.load(request)
        }).disposed(by: bag)
    }
    
    func handleUpdateVideoController(_ player: AVPlayer) {
        if videoController != nil {
            videoController.view.removeFromSuperview()
            videoController.player?.pause()
        }
        
        videoController.showsPlaybackControls = false
        videoController.player = player
        
        addChild(videoController)
        videoController.view.frame = videoView.bounds
        videoController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        videoView.addSubview(videoController.view)
        videoController.didMove(toParent: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loadPlayer" {
            videoController = segue.destination as? AVPlayerViewController
            guard videoController != nil else { print("video controller not accessed"); return }
            
            viewLoadedObservable.accept(true)
        }
    }
    
    @objc func showFlex() {
        #if canImport(FLEX)
        FLEXManager.shared.showExplorer()
        #endif
    }
}

extension StreamViewerController: AVPlayerViewControllerDelegate {
    @IBAction func handlePlayPauseButton(_ sender: UIButton) {
        if videoController.player?.timeControlStatus == .playing {
            videoController.player?.pause()
            controlButton.setTitle("\u{f04b}", for: .normal)
        } else {
            videoController.player?.play()
            controlButton.setTitle("\u{f04c}", for: .normal)
        }
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
