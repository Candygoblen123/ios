//
//  HomeViewController.swift
//  ios
//
//  Created by Mason Phillips on 1/7/21.
//

import UIKit
import Reusable

class HomeViewController: UIViewController, StoryboardBased {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let pasteboard = UIPasteboard.general.urls ?? []
        
        for url in pasteboard {
            if let url = URLComponents(url: url, resolvingAgainstBaseURL: false), (url.host == "youtube.com" || url.host == "youtu.be") {
                let alert = UIAlertController(title: "Youtube Link Detected!", message: "We detected a Youtube link in your clipboard. Would you like to access this stream?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Let's Go!", style: .default, handler: { _ in
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    alert.dismiss(animated: true, completion: nil)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
