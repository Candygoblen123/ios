//
//  BaseModel.swift
//  ios
//
//  Created by Mason Phillips on 1/7/21.
//

import Foundation
import RxCocoa
import RxFlow
import RxSwift

class BaseModel: NSObject {
    let services: AppService
    let stepper : Stepper
    
    let errorRelay = BehaviorRelay<Error?>(value: nil)
    let bag = DisposeBag()
    
    required init(_ items: ControllerInitializationItems) {
        services = items.services
        stepper = items.stepper
    }
}
