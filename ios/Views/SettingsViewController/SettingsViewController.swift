//
//  SettingsViewController.swift
//  ios
//
//  Created by Mason Phillips on 1/26/21.
//

import UIKit
import Eureka
import Reusable
import RxSwift
import SwiftyUserDefaults

class SettingsViewController: FormViewController, StoryboardBased, BaseController {
    var model: SettingsViewModel!
    let bag = DisposeBag()

    let settings = AppSettings.shared
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form
            +++ Section("Message Settings")
        
            <<< MultipleSelectorRow<String>("lang_select") { row in
                row.options = TranslatedLanguageTag.allCases.map { $0.description }
                row.value = Set(settings.languages.map { $0.description })
                row.title = "Languages"
                row.noValueDisplayText = "No languages selected"
                row.displayValueFor = { values -> String? in
                    values.map { $0.map { $0.description } }?.joined(separator: ", ")
                }
            }.onChange { row in
                if let value = row.value {
                    self.settings.languages = Array(value).compactMap { TranslatedLanguageTag($0) }
                }
            }
        
            <<< SwitchRow("mod_enabled") { row in
                row.title = "Mod Messages"
                row.value = settings.modMessages
            }.onChange { row in
                if let value = row.value {
                    self.settings.modMessages = value
                }
            }
            
            <<< SwitchRow("timestamps_enabled") { row in
                row.title = "Show Timestamps"
                row.value = settings.timestamps
            }.onChange { row in
                if let value = row.value {
                    self.settings.timestamps = value
                }
            }
        
            +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete],
                                   header: "Allowed Users",
                                   footer: "These users are always shown, even if they don't translate a message") { section in
                
                section.tag = "always_users_section"
                
                section.addButtonProvider = { section in
                    return ButtonRow(){
                        $0.title = "Tap to Add User"
                    }
                }
                section.multivaluedRowToInsertAt = { index in
                    return AccountRow() {
                        $0.placeholder = "Username"
                    }
                }
                
                for user in settings.alwaysUsers {
                    section <<< AccountRow() {
                        $0.placeholder = "Username"
                        $0.value = user
                    }
                }
                
                section <<< AccountRow() {
                    $0.placeholder = "Username"
                }
            }
        
            +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete],
                                   header: "Blocked Users",
                                   footer: "These users are never shown, even if they translate a message") { section in
                section.tag = "never_users_section"
                
                section.addButtonProvider = { section in
                    return ButtonRow(){
                        $0.title = "Tap to Add User"
                    }
                }
                section.multivaluedRowToInsertAt = { index in
                    return AccountRow() {
                        $0.placeholder = "Username"
                    }
                }
                
                for user in settings.neverUsers {
                    section <<< AccountRow() {
                        $0.placeholder = "Username"
                        $0.value = user
                    }
                }
                
                section <<< AccountRow() {
                    $0.placeholder = "Username"
                }
            }
    }
    
    @objc func viewDone() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func settingsDone() {
        let values = form.values()
        
        if let always = values["always_users_section"] as? Array<String> {
            settings.alwaysUsers = always
        }
        if let never = values["never_users_section"] as? Array<String> {
            settings.neverUsers = never
        }
        
        model.stepper.steps.accept(AppStep.settingsDone)
    }
}
