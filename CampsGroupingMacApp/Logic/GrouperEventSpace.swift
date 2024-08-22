import Foundation

typealias GrouperState = GrouperEventSpace.State
typealias GrouperEvent = GrouperEventSpace.Event
typealias GrouperAction = GrouperEventSpace.Action
typealias APIEvent = GrouperEvent.APIEvent
typealias SignInFormEvent = GrouperEvent.SignInFormEvent
typealias MenuEvent = GrouperEvent.MenuEvent
typealias CampSpecificEvent = GrouperEvent.CampSpecificEvent

enum GrouperEventSpace: EventSpace {
    struct State: Equatable {
        var hasLaunched: Bool = false
        var signInFormState: SignInFormState? = SignInFormState()
        var accessAccount: CampAccessAccount?
        var campScope: CampsScope?

        var activeFetches: Set<NetworkCall> = []
        var errors: Set<NetworkError> = []

        var navigationMode: NavigationMode = .signin
        var camps: [Camp] = []
        var selectedCamp: Int?
        var groupingState: CamperGroupingState?
    }

    enum Event: Equatable {
        case didBegin
        case didGetInitialCache(AppLogin?)
        case api(event: APIEvent)
        case signIn(event: SignInFormEvent)
        case menu(event: MenuEvent)
        case camp(event: CampSpecificEvent)
        case grouping(event: CamperGroupingEvent)
    }

    enum Action {
        case getInitialCache
        case signIn(
            username: String,
            password: String,
            scope: CampsScope,
            networkCall: NetworkCall
        )
        case getCamps(
            account: CampAccessAccount,
            scope: CampsScope,
            networkCall: NetworkCall
        )
        case getGroupsForCamp(
            camp: Camp,
            scope: CampsScope,
            networkCall: NetworkCall
        )
        case getReports(networkCall: NetworkCall)
        case getReportForCamp(campSettings: CampSettings, networkCall: NetworkCall)
        case getReportFormatForCamp(campSettings: CampSettings, networkCall: NetworkCall)
        case getCamperSettingsForCamp(camp: Camp, networkCall: NetworkCall)
        case setReportForCamp(reportID: String, camp: Camp, userID: Int, networkCall: NetworkCall)
        case updateReportFormatForCamp(
            campSettings: CampSettings,
            fieldsToUpdate: [ReportFieldSetting],
            userID: Int,
            networkCall: NetworkCall
        )
        case setCamperAssigmentsForCamp(camp: Camp, campSettings: CampSettings, camperChanges: [CamperSetting], userID: Int, networkCall: NetworkCall)
        // auto grouping
        case generateAutoGrouping(
            state: GrouperState,
            assigneeFilters: [FilterStep],
            groupFilters: [FilterStep],
            equivelencies: [String: Double],
            sizeMin: Int,
            sizeCap: Int
        )

        case uploadGroupAssignment(
            assignment: CamperAssignment,
            account: CampAccessAccount,
            scope: CampsScope,
            networkCall: NetworkCall
        )

        case markAssignmentAsUploaded(
            assignment: CamperAssignment,
            assignmentNotes: String,
            account: CampAccessAccount,
            camp: Camp,
            networkCall: NetworkCall
        )
    }

    static func handle(event: Event, state: inout State) -> [Action] {
        switch event {
        case .didBegin:
            let hasLaunched = state.hasLaunched
            state.hasLaunched = true
            return hasLaunched ? [] : [.getInitialCache]
        case .didGetInitialCache(let account):
            return InitialCacheReducer.handle(cache: account, state: &state)
        case .api(let event):
            return APIEventReducer.handle(event: event, state: &state)
        case .signIn(let event):
            return SignInFormEventReducer.handle(event: event, state: &state)
        case .menu(let event):
            return MenuEventReducer.handle(event: event, state: &state)
        case .camp(let event):
            return CampSpecificEventReducer.handle(event: event, state: &state)
        case .grouping(let event):
            return GroupingEventReducer.handle(event: event, state: &state)
        }
    }
}

struct FilterStep: Equatable {
    let step: FilterStepType
    let filter: FieldFilter
}

enum FilterStepType: Equatable {
    case AND, OR
}

