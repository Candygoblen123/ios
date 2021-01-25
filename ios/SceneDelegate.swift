//
//  SceneDelegate.swift
//  ios
//
//  Created by Mason Phillips on 1/7/21.
//

import UIKit
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
        Flows.use(flow, when: .created) { [weak window] root in
            window?.rootViewController = root
            window?.makeKeyAndVisible()
        }
        
        coordinator.rx.willNavigate.subscribe(onNext: { args in
            print("WN \(args.0) -> \(args.1)")
        }).disposed(by: bag)
        coordinator.rx.didNavigate.subscribe(onNext: { args in
            print("DN \(args.0) -> \(args.1)")
        }).disposed(by: bag)
        
        coordinator.coordinate(flow: flow, with: flow.stepper)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            switch url.scheme {
            case "livetl-translate":
                let id = url.path.replacingOccurrences(of: "/", with: "")
                coordinator.navigate(to: AppStep.view(id: id))

            // Will change this...eventually...
            case "livetl-auth":
                break
                
            default: break
            }
        }
    }
}
