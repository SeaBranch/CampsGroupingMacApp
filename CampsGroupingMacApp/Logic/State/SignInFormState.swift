import Foundation

struct SignInFormState: Equatable {
    private enum Constant {
        static let minPasswordLength = 1
        static let emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/
    }

    var email: String = ""
    var password: String = ""
    var scope: CampsScope = .camps

    var isValidFormData: Bool {
        isValidEmail && isValidPassword
    }

    var isValidEmail: Bool {
        (try? Constant.emailRegex.wholeMatch(in: email) != nil) ?? false
    }

    var isValidPassword: Bool {
        password.count >= Constant.minPasswordLength
    }
}
