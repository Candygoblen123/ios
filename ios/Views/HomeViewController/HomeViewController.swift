//
//  HomeViewController.swift
//  ios
//
//  Created by Mason Phillips on 1/7/21.
//

import UIKit
import SafariServices
import OAuthSwift
import RxFlow
import RxSwift
import Reusable
import FLEX

class HomeViewController: UIViewController, StoryboardBased, BaseController {
    var model: HomeModel!
    var stepper: Stepper!
    
    var oauth: OAuth2Swift!
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
                    
                    self.stepper.steps.accept(AppStep.view(id: final))
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    alert.dismiss(animated: true, completion: nil)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func showFlex() {
        FLEXManager.shared.showExplorer()
    }
}
