//
//  TranslatedLanguageTag.swift
//  ios
//
//  Created by Mason Phillips on 1/28/21.
//

import Foundation

enum TranslatedLanguageTag: String, CustomStringConvertible, CaseIterable {
    case en, jp, es, id, kr, zh, ru, fr
    case dev
    
    var description: String {
        switch self {
        case .en: return "English"
        case .jp: return "Japanese"
        case .es: return "Spanish"
        case .id: return "Indonesian"
        case .kr: return "Korean"
        case .zh: return "Chinese"
        case .ru: return "Russian"
        case .fr: return "French"
            
        case .dev: return "Developer Tags"
        }
    }
    
    var tag: String {
        switch self {
        case .en: return "en"
        case .jp: return "jp"
        case .es: return "es"
        case .id: return "id"
        case .kr: return "kr"
        case .zh: return "zh"
        case .ru: return "ru"
        case .fr: return "fr"

        case .dev: return "dev"
        }
    }
}

