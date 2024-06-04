//
//  Strings.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/4/24.
//

import SwiftUI

// MARK: Raw Constants
enum StringConstant {
    static let check = "􀁣"
    static let circleX = "􀀳"
}

// MARK: Localized Strings

enum Strings: String.LocalizationValue, LocalizedStringEnum {
    case email, password, signIn, signOut, aCampAccess, selectACampsCategory, loading, signingIn
}

// MARK: Protocols and Extensions

protocol LocalizedStringEnum {
    var rawValue: String.LocalizationValue { get }
    var value: String { get }

    func value(_ arguments: CVarArg...) -> String
}

extension LocalizedStringEnum {
    var value: String {
        String(localized: rawValue)
    }

    func value(_ arguments: CVarArg...) -> String {
        String(format: value, arguments: arguments)
    }
}

extension Text {
    init(_ stringEnum: LocalizedStringEnum) {
        self.init(verbatim: stringEnum.value)
    }

    init(_ stringEnum: LocalizedStringEnum, _ arguments: CVarArg...) {
        self.init(verbatim: stringEnum.value(arguments))
    }
}
