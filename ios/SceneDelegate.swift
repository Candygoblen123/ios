//
//  SceneDelegate.swift
//  ios
//
//  Created by Mason Phillips on 1/7/21.
//

import UIKit
import GoogleSignIn
import RxFlow
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let coordinator = FlowCoordinator()
    let bag = DisposeBag()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        let flow = AppFlow()
        Flows.use(flow, when: .ready) { [weak window] root in
            window?.rootViewController = root
            window?.makeKeyAndVisible()
        }
        
        coordinator.coordinate(flow: flow, with: flow.stepper)
        
        GIDSignIn.sharedInstance()?.clientID = "626233357823-qpb2o7vroh74h3uf9vs27dtsmfnaj2j2.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()?.delegate = self
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            switch url.scheme {
            case "livetl-translate":
                let id = url.path.replacingOccurrences(of: "/", with: "")
                coordinator.navigate(to: AppStep.view(id: id))
                break

            case "com.googleusercontent.apps.626233357823-qpb2o7vroh74h3uf9vs27dtsmfnaj2j2":
                GIDSignIn.sharedInstance()?.handle(url)
                
            default: break
            }
        }
    }
}

extension SceneDelegate: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            print(error!)
            return
        }
        
        print(user.profile.givenName ?? "UNK")
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("signed out \(user.userID ?? "UNKID")")
    }
}
