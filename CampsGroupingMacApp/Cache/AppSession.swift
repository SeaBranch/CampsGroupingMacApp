import Foundation
import SwiftData

@Model
class AppLogin {
    let accountId: String
    let firstName: String
    let lastName: String
    let email: String
    let accountNumber: Int
    let accessKey: String
    let isUser: Bool
    let avatarUrl: String
    let isBrushfireStaff: Bool
    let dateCreated: Date
    let scope: CampsScope?

    init(
        accountId: String,
        firstName: String,
        lastName: String, 
        email: String,
        accountNumber: Int,
        accessKey: String,
        isUser: Bool,
        avatarUrl: String,
        isBrushfireStaff: Bool,
        dateCreated: Date,
        scope: CampsScope
    ) {
        self.accountId = accountId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.accountNumber = accountNumber
        self.accessKey = accessKey
        self.isUser = isUser
        self.avatarUrl = avatarUrl
        self.isBrushfireStaff = isBrushfireStaff
        self.dateCreated = dateCreated
        self.scope = scope
    }

    static func fromAccount(
        _ account: CampAccessAccount,
        scope: CampsScope
    ) -> AppLogin {
        AppLogin(
            accountId: account.accountId,
            firstName: account.firstName,
            lastName: account.lastName,
            email: account.email,
            accountNumber: account.accountNumber,
            accessKey: account.accessKey,
            isUser: account.isUser,
            avatarUrl: account.avatarUrl,
            isBrushfireStaff: account.isBrushfireStaff,
            dateCreated: Date(),
            scope: scope
        )
    }

    var account: CampAccessAccount {
        CampAccessAccount(
            accountId: accountId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            accountNumber: accountNumber,
            accessKey: accessKey,
            isUser: isUser,
            avatarUrl: avatarUrl,
            isBrushfireStaff: isBrushfireStaff
        )
    }
}

@Model
class CampsStateMemory {
    var camps: [CampInfo]
    var dateCreated: Date
    let scope: CampsScope?

    init(camps: [CampInfo], dateCreated: Date, scope: CampsScope) {
        self.camps = camps
        self.dateCreated = dateCreated
        self.scope = scope
    }

    static func fromCamps(_ camps: [CampInfo], scope: CampsScope) -> CampsStateMemory {
        .init(camps: camps, dateCreated: Date(), scope: scope)
    }
}
