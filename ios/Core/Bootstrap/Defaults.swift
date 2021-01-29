//
//  Defaults.swift
//  ios
//
//  Created by Mason Phillips on 1/28/21.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    var languages   : DefaultsKey<[TranslatedLanguageTag]> { .init("languages", defaultValue: [.en]) }
    var mod_messages: DefaultsKey<Bool> { .init("mod_messages_enabled", defaultValue: true) }
    var timestamps  : DefaultsKey<Bool> { .init("timestamps_enabled", defaultValue: true) }
    
    var always_users: DefaultsKey<[String]> { .init("always_shown_users", defaultValue: []) }
    var never_users : DefaultsKey<[String]> { .init("never_shown_users", defaultValue: []) }
}

struct AppSettings {
    static var shared: AppSettings = AppSettings()
    
    @SwiftyUserDefault(keyPath: \.languages)
    var languages: [TranslatedLanguageTag]
    
    @SwiftyUserDefault(keyPath: \.mod_messages)
    var modMessages: Bool
    
    @SwiftyUserDefault(keyPath: \.timestamps)
    var timestamps: Bool
    
    @SwiftyUserDefault(keyPath: \.always_users)
    var alwaysUsers: [String]
    
    @SwiftyUserDefault(keyPath: \.never_users)
    var neverUsers: [String]
}

extension TranslatedLanguageTag: DefaultsSerializable, RawRepresentable {}
