//
//  HomeViewController.swift
//  ios
//
//  Created by Mason Phillips on 1/7/21.
//

import UIKit
import GoogleSignIn
import RxFlow
import Reusable

class HomeViewController: UIViewController, StoryboardBased {
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    var stepper: Stepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
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
}
