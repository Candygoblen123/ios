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
    
    @IBOutlet weak var barButton    : UIBarButtonItem!
    
    var videoController: AVPlayerViewController!
    
    var viewLoadedObservable = BehaviorRelay<Bool>(value: false)
    let chatEventObservable  = BehaviorRelay<(Double, String)?>(value: nil)
    
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
        
        model.chatUrl
            .compactMap { $0 }
            .subscribe(onNext: { url in
                DispatchQueue.main.async {
                    self.injectorView.load(URLRequest(url: url))
                }
            }).disposed(by: bag)
        
        Observable.combineLatest(model.replayControl, chatEventObservable).filter { $0.0 == true }
            .compactMap { $0.1 }
            .subscribe(onNext: { (time, id) in
                let js = """
                    window.postMessage({ "yt-player-video-progress": \(time), video: "\(id)"}, '*');
                """
                
                DispatchQueue.main.async {
                    self.injectorView.evaluateJavaScript(js, completionHandler: nil)
                }
            }).disposed(by: bag)
        
        barButton.setTitleTextAttributes([
            .font: UIFont(name: "FontAwesome5Pro-Regular", size: 20)!,
        ], for: .normal)
        barButton.setTitleTextAttributes([
            .font: UIFont(name: "FontAwesome5Pro-Regular", size: 20)!,
        ], for: .selected)
        
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
            XCDYouTubeClient.default().getVideoWithIdentifier(id) { (video, error) in
                guard error == nil else { print(error!); return }
                
                if let video = video {
                    self?.handleUpdateVideoController(video)
                    self?.model.performChatLoad(video.identifier, duration: video.duration)
                } else { print("cant get video") }
            }
        }).disposed(by: bag)
    }
    
    func handleUpdateVideoController(_ video: XCDYouTubeVideo) {
        if videoController != nil {
            videoController.view.removeFromSuperview()
            videoController.player?.pause()
            videoController = nil
        }
        
        videoController = AVPlayerViewController()
        videoController.delegate = self
        videoController.player = AVPlayer(url: video.streamURL!)
        
        addChild(videoController)
        videoController.view.frame = videoView.bounds
        videoController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        videoView.addSubview(videoController.view)
        videoController.didMove(toParent: self)

        let time = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        videoController.player?.addPeriodicTimeObserver(forInterval: time, queue: .main) { time in
            self.chatEventObservable.accept((time.seconds, video.identifier))
        }
    }
    
    @IBAction func handleMenu() {
        model.stepper.steps.accept(AppStep.settings)
    }
    
    @objc func showFlex() {
        #if canImport(FLEX)
        FLEXManager.shared.showExplorer()
        #endif
    }
}

extension StreamViewerController: AVPlayerViewControllerDelegate {}

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

extension TimeInterval {
    func stringFromTimeInterval() -> String {
        let seconds = self.truncatingRemainder(dividingBy: 60)
        let minutes = (self / 60).truncatingRemainder(dividingBy: 60)
        let hours = (self / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
