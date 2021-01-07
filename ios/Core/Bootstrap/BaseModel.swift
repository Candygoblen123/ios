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
    let bag = DisposeBag()
    
    required init(_ stepper: Stepper) {
        
    }
}
