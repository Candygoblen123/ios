//
//  AppFlow.swift
//  ios
//
//  Created by Mason Phillips on 1/7/21.
//

import UIKit
import RxCocoa
import RxSwift
import RxFlow

class AppFlow: Flow {
    var root: Presentable { return rootViewController }
    let rootViewController = UINavigationController()
    let stepper = AppStepper()
    let services = AppService()
    
    init() {
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .home: return toHome()
        case .view(let id): return toStream(id)
        case .settings: return toSettings()
            
        case .settingsDone: return doneSettings()
        case .viewDone: return doneView()
            
        default: return .none
        }
    }
    
    private func toHome() -> FlowContributors {
        let controller = HomeViewController.instantiate(self.stepper, services: services)        
        rootViewController.pushViewController(controller, animated: true)

        return .none
    }
    private func toStream(_ id: String) -> FlowContributors {
        let controller = StreamViewerController.instantiate(self.stepper, services: services)
        controller.loadStreamWithId(id: id)
        rootViewController.pushViewController(controller, animated: true)
        
        return .none
    }
    private func toSettings() -> FlowContributors {
        let controller = SettingsViewController.instantiate(self.stepper, services: services)
        
        let nav = UINavigationController(rootViewController: controller)
        rootViewController.present(nav, animated: true, completion: nil)
        
        return .none
    }
    
    private func doneSettings() -> FlowContributors {
        rootViewController.dismiss(animated: true, completion: nil)
        return .none
    }
    private func doneView() -> FlowContributors {
        rootViewController.popViewController(animated: true)
        return .none
    }
    
    @objc func handleMenu() {}
}

struct AppStepper: Stepper {
    let steps = PublishRelay<Step>()
    let initialStep: Step = AppStep.home
    
    func readyToEmitSteps() {
//        steps.accept(initialStep)
    }
}
