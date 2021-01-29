//
//  AppDelegate.swift
//  ios
//
//  Created by Mason Phillips on 1/7/21.
//

import UIKit
import RxFlow
import RxSwift
import FontBlaster

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let coordinator = FlowCoordinator()
    let bag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        FontBlaster.blast()
        
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

        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        switch url.scheme {
        case "livetl-translate":
            let id = url.path.replacingOccurrences(of: "/", with: "")
            coordinator.navigate(to: AppStep.view(id: id))
            
            return true

        // Will change this...eventually...
        case "livetl-auth":
            fallthrough
        
        default: return false
        }
    }
}

