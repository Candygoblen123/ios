//
//  AppStep.swift
//  ios
//
//  Created by Mason Phillips on 1/7/21.
//

import RxFlow

enum AppStep: Step {
    case home
    case view(id: String)
    case settings
    
    case viewDone
    case settingsDone
}
