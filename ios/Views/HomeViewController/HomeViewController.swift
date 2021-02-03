//
//  HomeViewController.swift
//  ios
//
//  Created by Mason Phillips on 1/7/21.
//

import UIKit
import SafariServices
import RxFlow
import RxSwift
import RxDataSources
import Reusable

#if canImport(FLEX)
    import FLEX
#endif

class HomeViewController: UIViewController, StoryboardBased, BaseController {
    var model: HomeViewModel!
    var stepper: Stepper!
    
    let bag = DisposeBag()
    
    @IBOutlet weak var barButton: UIBarButtonItem!
    
    @IBOutlet weak var liveCollection: UICollectionView!
    
    var gesture: UITapGestureRecognizer {
        let g = UITapGestureRecognizer(target: self, action: #selector(showFlex))
        g.numberOfTouchesRequired = 2
        g.numberOfTapsRequired = 2
        return g
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(gesture)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<Void, String>> { (source, view, index, item) -> UICollectionViewCell in
            let cell = view.dequeueReusableCell(for: index) as LiveCard
            
            return cell
        }
        
        liveCollection.register(cellType: LiveCard.self)
        Observable.just(Array(repeating: "asdf", count: 10))
            .map { [SectionModel<Void, String>(model: (), items: $0)] }
            .bind(to: liveCollection.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkPasteboard),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        barButton.setTitleTextAttributes([
            .font: UIFont(name: "FontAwesome5Pro-Regular", size: 20)!,
        ], for: .normal)
        barButton.setTitleTextAttributes([
            .font: UIFont(name: "FontAwesome5Pro-Regular", size: 20)!,
        ], for: .selected)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkPasteboard()
    }
    
    @objc func checkPasteboard() {
        let pasteboard = UIPasteboard.general.urls ?? []
        
        for url in pasteboard {
            if let url = URLComponents(url: url, resolvingAgainstBaseURL: false), (url.host == "youtube.com" || url.host == "youtu.be") {
                let alert = UIAlertController(title: "Youtube Link Detected!", message: "We detected a Youtube link in your clipboard. Would you like to access this stream?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Let's Go!", style: .default, handler: { [url] _ in
                    let final: String
                    
                    if let id = url.queryItems?.filter({ $0.name == "v" }).first?.value {
                        final = id
                    } else {
                        final = url.path.replacingOccurrences(of: "/", with: "")
                    }
                    
                    self.model.stepper.steps.accept(AppStep.view(id: final))
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    alert.dismiss(animated: true, completion: nil)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
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
