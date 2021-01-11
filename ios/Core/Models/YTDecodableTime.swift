//
//  YTDecodableTime.swift
//  ios
//
//  Created by Mason Phillips on 1/11/21.
//

import Foundation

struct YTDecodableDateTime: Decodable, Equatable {
    let value: Date
    
    init(from decoder: Decoder) throws {
        let context = try decoder.singleValueContainer()
        let str = try context.decode(String.self)
        guard let value = str.toDate()?.date else {
            throw DecodingError.dataCorruptedError(in: context, debugDescription: "Expected to decode Date but found unexpected string")
        }
        self.value = value
    }
    
    static func >(l: Self, r: Self) -> Bool {
        return l.value > r.value
    }
    static func <(l: Self, r: Self) -> Bool {
        return l.value < r.value
    }
    static func ==(l: Self, r: Self) -> Bool {
        return l.value == r.value
    }
}
