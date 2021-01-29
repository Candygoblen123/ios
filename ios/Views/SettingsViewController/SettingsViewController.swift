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

class SettingsViewController: FormViewController, StoryboardBased, BaseController {
    var model: SettingsViewModel!
    let bag = DisposeBag()

    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form
            +++ Section("Message Settings")
        
            <<< MultipleSelectorRow<String>("lang_select") { row in
                row.options = TranslatedLanguageTag.allCases.map { $0.description }
                row.title = "Languages"
                row.noValueDisplayText = "No languages selected"
                row.displayValueFor = { values -> String? in
                    values?.joined(separator: ", ")
                }
            }
        
            <<< SwitchRow("mod_enabled") { row in
                row.title = "Mod Messages"
                row.value = true
            }
            
            <<< SwitchRow("timestamps_enabled") { row in
                row.title = "Show Timestamps"
                row.value = true
            }
        
            +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete],
                                   header: "Allowed Users",
                                   footer: "These users are always shown, even if they don't translate a message") { row in
                
                row.addButtonProvider = { section in
                    return ButtonRow(){
                        $0.title = "Tap to Add User"
                    }
                }
                row.multivaluedRowToInsertAt = { index in
                    return AccountRow() {
                        $0.placeholder = "Username"
                    }
                }
                row <<< AccountRow() {
                    $0.placeholder = "Username"
                }
            }
        
            +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete],
                                   header: "Blocked Users",
                                   footer: "These users are never shown, even if they translate a message") { row in
                
                row.addButtonProvider = { section in
                    return ButtonRow(){
                        $0.title = "Tap to Add User"
                    }
                }
                row.multivaluedRowToInsertAt = { index in
                    return AccountRow() {
                        $0.placeholder = "Username"
                    }
                }
                row <<< AccountRow() {
                    $0.placeholder = "Username"
                }

            }

    }
    
    @objc func viewDone() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func settingsDone() {
        model.stepper.steps.accept(AppStep.settingsDone)
    }
}
