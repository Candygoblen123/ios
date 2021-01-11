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
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .home: return toHome()
        case .view(let id): return toStream(id)
            
        default: return .none
        }
    }
    
    private func toHome() -> FlowContributors {
        let controller = HomeViewController.instantiate(self.stepper, services: services)
        controller.stepper = self.stepper
        
        rootViewController.setViewControllers([controller], animated: true)
        
        return .none
    }
    private func toStream(_ id: String) -> FlowContributors {
        let controller = StreamViewerController.instantiate(self.stepper, services: services)
        controller.loadStreamWithId(id: id)
        rootViewController.setViewControllers([controller], animated: true)
        
        return .none
    }
}

struct AppStepper: Stepper {
    let steps = PublishRelay<Step>()
    let initialStep: Step = AppStep.home
    
    func readyToEmitSteps() {
        steps.accept(initialStep)
    }
}
