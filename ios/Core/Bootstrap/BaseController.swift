//
//  BaseController.swift
//  ios
//
//  Created by Mason Phillips on 1/7/21.
//

import UIKit
import RxCocoa
import RxFlow
import RxSwift
import Reusable

protocol BaseController {
    associatedtype Model: BaseModel
    
    var model: Model! { get set }
}

extension StoryboardBased where Self: UIViewController & BaseController {
    static func instantiate(_ stepper: Stepper) -> Self {
        var controller = Self.instantiate()
        
        let model = Self.Model.init(stepper)
        controller.model = model
        
        return controller
    }
}
