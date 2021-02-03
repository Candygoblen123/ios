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
import SCLAlertView

typealias ControllerInitializationItems = (services: AppService, stepper: AppStepper)
//
//protocol BaseControllerType {
//    var bag  : DisposeBag { get }
//    
//    init(initializationItems: ControllerInitializationItems)
//    
//    func handle(error: Error)
//}
//
//class BaseController: UIViewController, BaseControllerType {
//    let bag = DisposeBag()
//    
//    required init(initializationItems: ControllerInitializationItems) {
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        model.errorRelay.compactMap { $0 }
//            .subscribe(onNext: handle(error:))
//            .disposed(by: bag)
//        
//        view.backgroundColor = .systemBackground
//    }
//    
//    func handle(error: Error) {
//        SCLAlertView().showError("An error occurred", subTitle: error.localizedDescription)
//    }
//    
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError()
//    }
//}
//
