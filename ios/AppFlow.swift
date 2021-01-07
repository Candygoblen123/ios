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
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .home:
            rootViewController.setViewControllers([StreamViewerController.instantiate(self.stepper)],
                                                  animated: false)
            return .none
        case .view(let id):
            let controller = StreamViewerController.instantiate(self.stepper)
            controller.loadStreamWithId(id: id)
            rootViewController.setViewControllers([controller], animated: false)
            
            return .none
            
        default: return .none
        }
    }
}

struct AppStepper: Stepper {
    let steps = PublishRelay<Step>()
    let initialStep: Step = AppStep.home
    
    func readyToEmitSteps() {
        steps.accept(initialStep)
    }
}
