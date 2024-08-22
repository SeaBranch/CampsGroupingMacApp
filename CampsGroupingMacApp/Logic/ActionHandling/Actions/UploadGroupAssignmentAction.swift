import Foundation

typealias UploadGroupAssignmentResult = Result<GroupingAsignment, CampsGroupingAPIError>

struct UploadGroupAssignmentData:
    Equatable,
    CampGroupingAPIUpdateEndpointModel {

    typealias D = UploadGroupAssignmentResponseDTO

    let camper: Camper
    let groupID: GroupIdentification
    let account: CampAccessAccount
    let scope: CampsScope
    var endpoint: CampsGroupingEndpoint

    var body: any RequestDTO {
        UploadGroupAssignmentRequestDTO(
            groupId: groupID.groupId,
            overrideCommunityCapacity: false,
            accessKey: account.accessKey
        )
    }

    init(
        assignment: CamperAssignment,
        account: CampAccessAccount,
        scope: CampsScope
    ) {
        self.camper = assignment.camper
        self.groupID = assignment.group
        self.account = account
        self.scope = scope
        self.endpoint = .uploadCamperGroup(
            camper: assignment.camper
        )
    }
}

struct UploadGroupAssignmentRequestDTO: RequestDTO {
    let groupId: String
    let overrideCommunityCapacity: Bool
    let accessKey: String

    enum CodingKeys: String, CodingKey {
        case groupId = "GroupId"
        case overrideCommunityCapacity = "OverrideCommunityCapacity"
        case accessKey = "AccessKey"
    }
}

struct UploadGroupAssignmentResponseDTO: Codable {
    let Id: String?
    let AttendeeNumber: Int?
    let AttendeeCode: String?
    let EventId: String?
    let EventNumber: Int?
    let Status: String?
    let IsCompleted: Bool?
    let IsGift: Bool?
    let IsPreRegistered: Bool?
    let IsPrinted: Bool?
    let ShareEmail: String?
    let GiftLastSentAt: String?
    let FirstName: String?
    let LastName: String?
    let Phone: String?
    let Email: String?
    let Street1: String?
    let Street2: String?
    let City: String?
    let Region: String?
    let Country: String?
    let PostalCode: String?
    let TypeId: String?
    let TypeName: String?
    let SectionName: String?
    let RowName: String?
    let SeatLabel: String?
    let Wheelchair: String?
    let LimitedView: String?
    let Amount: Double?
    let SeatInfo: String?
    let CommunityId: String?
    let CommunityName: String?
    let CommunityPartition: String?
    let GroupId: String?
    let GroupName: String?
    let GroupEmail: String?
    let Fields: [GroupField]?
    let OrderFields: [GroupField]?
    let GroupFields: [GroupField]?
    let Checkins: [Checkin]?
    let IsAnonymized: Bool?
    let AttendeeDisplay: [String: String]?
    let OrderedAt: String?
    let ShareEnabled: Bool?

    struct Checkin: Codable {
        let Name: String?
        let SessionNumber: Int?
        let CheckedInAt: String?
        let CheckedIn: Bool?
        let IsHidden: Bool?
    }

    struct GroupField: Codable {
        let Id: String?
        let Label: String?
        let Value: String?
        let groupFieldType: String?
        let IsSensitive: Bool?
        let OptionIds: [String]?

        enum CodingKeys: String, CodingKey {
            case Id
            case Label
            case Value
            case groupFieldType = "Type"
            case IsSensitive
            case OptionIds
        }
    }
}

extension NetworkActionHandler {
    func handleUploadGroupAssignment(
        assignment: CamperAssignment,
        scope: CampsScope,
        account: CampAccessAccount,
        networkCall: NetworkCall,
        handleEvent: @escaping (GrouperEventSpace.Event) -> Void
    ) {
        let data = UploadGroupAssignmentData(
            assignment: assignment,
            account: account,
            scope: scope
        )

        uploadGroupingLogicController.uploadGrouping(
            requestData: data
        ) { result in
            handleEvent(
                .api(event: .didRespondToUploadCamperGrouping(
                    result: result,
                    requestData: data,
                    networkCall: networkCall
                ))
            )
        }
    }
}
