import Foundation

enum InitialCacheReducer {
    static func handle(
        cache: AppLogin?,
        state: inout GrouperState
    ) -> [GrouperAction] {
        guard let currentLogin = cache,
              Date()
            .timeIntervalSince(currentLogin.dateCreated) <= TimeInterval(24 * 60 * 60),
              let scope = currentLogin.scope
        else {
            return []
        }

        let account = currentLogin.account

        state.accessAccount = account
        state.signInFormState = nil
        state.campScope = scope
        state.navigationMode = .camps

        return [state.beginGetCamps(account: account, scope: scope)]
    }
}
