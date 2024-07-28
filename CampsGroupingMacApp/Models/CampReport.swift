import Foundation
import SwiftCSV

enum ReportID: String, CaseIterable {
    case fatherSonDemo = "https://app.brushfire.com/r/b2abb5b6-4e02-434e-b897-ccb18fce25aa/export"

    func getReport(result: @escaping (Result<Report, NSError>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                if let csv = try? CSV<Named>(url: URL(string: self.rawValue)!) {
                    let report  = Report(csv: csv, campID: campID)
                    DispatchQueue.main.async {
                        result(.success(report))
                    }
                } else {
                    throw NSError(domain: "csv", code: 404)
                }
            } catch {
                let nsError = error as NSError
                DispatchQueue.main.async {
                    result(.failure(nsError))
                }
            }
        }
    }

    var campID: Int {
        switch self {
        case .fatherSonDemo: 573184
        }
    }

    var scope: CampsScope {
        switch self {
        case .fatherSonDemo: .sandbox
        }
    }

    static func forCamp(_ camp: Camp) -> ReportID? {
        Self.allCases.first { reportID in
            reportID.campID == camp.eventNumber
        }
    }
}

typealias ReportRow = [String: ReportFieldValue?]

struct Report: Equatable {
    let csv: CSV<Named>
    let campID: Int
    var fields: [ReportField]
    
    var rows: [ReportRow] {
        csv.rows.map { rowData in
            var values = ReportRow()
            for field in fields {
                values[field.fieldName] = value(for: field, in: rowData)
            }
            return values
        }
    }

    var rowCount: Int {
        csv.rows.count
    }

    init(csv: CSV<Named>, campID: Int) {
        self.csv = csv
        self.campID = campID
        fields = csv.columns?.keys.map({ key in
            ReportField(fieldName: key)
        }) ?? []
    }

    func value(for field: ReportField, in row: [String: String]) -> ReportFieldValue? {
        field.value(for: row[field.fieldName])
    }

    func withChangedField(_ changedField: ReportField) -> Self {
        var changedReport = self
        changedReport.fields = fields.map({ field in
            if field.fieldName == changedField.fieldName {
                changedField
            } else {
                field
            }
        })
        return changedReport
    }

    func asCamperRows(existingCampers: [Camper] = []) -> [CamperRow] {
        CamperRow.arrayFromReportAndData(self, campers: existingCampers)
    }
}


struct ReportField: Equatable, Identifiable {
    var id: String {
        fieldName
    }

    let fieldName: String
    var fieldType: ReportFieldType = .string
    var visable: Bool = false
    var showInTable: Bool = false
    var includeInGrouping: Bool = false
    var handleDirectly: Bool = false
    var equivalance: Double = 1
    var differenceIfMissing: Double = 1

    func value(for rawValue: String?) -> ReportFieldValue {
        if let string = rawValue {
            switch fieldType {
            case .string: .string(string)
            case .fullName: .fullName(string)
            case .partOfName: .partOfName(string)
            case .int: .int(Int(string), string)
            case .bool: .bool(Bool(string), string)
            case .zip: .zip(ZipLocation.fromZipString(string), string)
            case .camperID: .camperID(Int(string), string)
            case .groupID: .groupID(Int(string), string)
            case .crossroadsSite: .crossroadsSite(string)
            }
        } else {
            .empty
        }
    }
}

enum ReportFieldValue: Equatable, Hashable {
    case string(String)
    case fullName(String)
    case partOfName(String)
    case int(Int?, String)
    case bool(Bool?, String)
    case zip(ZipLocation?, String)
    case camperID(Int?, String)
    case groupID(Int?, String)
    case crossroadsSite(String)
    case empty

    func difference(from other: ReportFieldValue, with equivalance: Double) -> Double? {
        switch self {
        case .string(let stringL):
            if case .string(let stringR) = other {
                return (stringL == stringR ? 0 : 1) * equivalance
            }

        case .crossroadsSite(let stringL):
            if case .crossroadsSite(let stringR) = other {
                return (stringL == stringR ? 0 : 1) * equivalance
            }

        case .int(let intL, _):
            if case .int(let intR, _) = other,
               let ourInt = intL,
               let otherInt = intR
            {
                return Double(abs(ourInt - otherInt)) * equivalance
            }

        case .bool(let bool, _):
            if case .bool(let otherBool, _) = other,
               let bool = bool,
               let otherBool = otherBool {
                return (bool == otherBool ? 0 : 1) * equivalance
            }

        case .zip(let zipLocation, _):
            if case .zip(let otherZip, _) = other,
               let location = zipLocation?.location,
               let otherLocation = otherZip?.location {
                return location.distance(from: otherLocation) * equivalance
            }

        default:
            return nil
        }

        return nil
    }

    var rawValue: String {
        switch self {
        case .string(let string):           string
        case .fullName(let string):         string
        case .partOfName(let string):       string
        case .int(_, let string):           string
        case .bool(_, let string):          string
        case .zip(_, let string):           string
        case .camperID(_, let string):      string
        case .groupID(_, let string):       string
        case .crossroadsSite(let string):   string
        case .empty:                        ""
        }
    }
}

enum ReportFieldType: String, Equatable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case string,
         fullName,
         partOfName,
         int,
         bool,
         zip,
         camperID,
         groupID,
         crossroadsSite
}

struct FatherSonReportRow {
let attendeeId: String // "5bf064ac-ab7e-40b2-896f-181f853fa793"
let attendeeNumber: Int // "97251833"
let attendeeCode: String // ""
let attendeeStatus: String // "Reserved"
let typeName: String // "Father and Son - HQ"
let completed: Bool // "True"
let preRegistered: Bool // "False"
let gift: String // "False"
let lastModified: String // "3/31/2024 6:30:05 AM"
let groupingToolGroup: Int // ""
let isTheAttendingFatherTheGuardian: Bool // "Yes"
let fatherFullName: String // "Bobberson, Bob"
let fatherFirstName: String // "Bob"
let fatherLastName: String // "Bobberson"
let sonFullName: String // "Bobberson, Jimbo"
let sonFirstName: String // "Jimbo"
let sonLastName: String // "Bobberson"
let fullAddress: String // "1234 Mcnabe Street, Florence, KY, 41042, US"
let addressStreet1: String // "1234 Mcnabe Street"
let addressStreet2: String // ""
let addressCity: String // "Florence"
let addressRegion: String // "KY"
let addressPostalCode: String // "41042"
let addressCountry: String // "US"
let addressCountryName: String // "United States"
let addressRegionName: String // "Kentucky"
let phoneNumber: String // "(555) 555-5555"
let fatherBirthdate: String // "1984-10-30"
let sonBirthdate: String // "2016-01-01"
let fatherMaritalStatus: String // "Married"
let kidsAges: [Int] // "6-12 years of age, 13-17 years of age"
let connectedToChurch: String // "Crossroads"
let church: String // ""
let crossroadsSite: String // "Florence"
let openMeetUps: String // ""
let openToOrganizingMeetUps: String // "Nope"
let fatherInCrossroadsGroup: String // "Nope"
let sonAgeAtCamp: Int // "8"
let groupingPrioritization: String // ""
let father1PreferenceFirstName: String // ""
let father1PreferenceLastName: String // ""
let son1PreferenceFirstName: String // ""
let son1PreferenceLastName: String // ""
let father2PreferenceFirstName: String // ""
let father2PreferenceLastName: String // ""
let son2PreferenceFirstName: String // ""
let son2PreferenceLastName: String // ""
let fatherEthnicity: String // "White"
let fatherEthnicityOther: String // ""
let sonEthnicity: String // "White"
let sonEthnicityOther: String // ""
let fatherAttendedThisCampBefore: String // "Attended multiple times before"
let was2023TheFirstYearAttending: String // ""
let fatherHasAttendedOtherCamps: Bool // "Nope"
let fatherOtherAttendedCamps: String // ""
let relationshipStrFatherAndSon: Int // "1"
let relationshipWithGod: Int // "4"
let groupNumber: String // ""
let groupId: String // ""
let groupName: String // ""
let groupType: String // ""
let groupEmail: String // ""
let groupAttendeeCount: String // ""
let selectAgeYourSonAtCamp: Int // ""
let eventNumber: Int // "574357"
let eventTitle: String // "Copy of Father Son Camp 2024"
let eventLocationAddress: String // "420 Neville-Penn Schoolhouse Road, Felicity, OH 45120 United States"
let eventLocationName: String // "Crossroads Camp"
let eventOrganizerEmail: String // "fathersoncamp@crossroads.net"
let eventOrganizerPhone: String // ""
let eventDateInfo: String // "Friday, May 31, 2024 4:00 PM - Sunday, Jun 2, 2024 1:00 PM EDT"
let eventClientKey: String // "campssb"
}

enum Report1Key: String, CaseIterable {
    case AttendeeId = "Attendee Id"
    case AttendeeNumber = "Attendee Number"
    case AttendeeCode = "Attendee Code"
    case AttendeeStatus = "Attendee Status"
    case TypeName = "Type Name"
    case TypeAcctCode = "Type Acct Code"
    case TypeAmount = "Type Amount"
    case AttendeeAmount = "Attendee Amount"
    case AddonsAmount = "Addons Amount"
    case DiscountAmount = "Discount Amount"
    case FeeAmount = "Fee Amount"
    case TaxAmount = "Tax Amount"
    case DeliveryAmount = "Delivery Amount"
    case AttendeeTotal = "Attendee Total"
    case OutstandingBalance = "Outstanding Balance"
    case PromotionsApplied = "Promotions Applied"
    case PromotionAmount = "Promotion Amount"
    case Completed = "Completed"
    case PreRegistered = "Pre-Registered"
    case Gift = "Gift"
    case GiftRecipientEmail = "Gift Recipient Email"
    case GiftDate = "Gift Date"
    case Printed = "Printed"
    case LastModified = "Last Modified"
    case GroupingToolGroup = "Grouping Tool Group"
    case IsTheAttendingFatherTheGuardian = "Is the attending father the parent or legal guardian of the attending son?"
    case FatherFullName = "Father (Figure) Full Name (Combined)"
    case FatherFirstName = "Father (Figure) Full Name (First)"
    case FatherLastName = "Father (Figure) Full Name (Last)"
    case SonFullName = "Son's Full Name (Combined)"
    case SonFirstName = "Son's Full Name (First)"
    case SonLastName = "Son's Full Name (Last)"
    case FullAddress = "Full Address (Combined)"
    case AddressStreet1 = "Full Address (Street1)"
    case AddressStreet2 = "Full Address (Street2)"
    case AddressCity = "Full Address (City)"
    case AddressRegion = "Full Address (Region)"
    case AddressPostalCode = "Full Address (PostalCode)"
    case AddressCountry = "Full Address (Country)"
    case AddressCountryName = "Full Address (CountryName)"
    case AddressRegionName = "Full Address (RegionName)"
    case PhoneNumber = "Phone Number"
    case CanText = "Can we text you?"
    case Email = "Email"
    case TShirtSizeFather = "T Shirt Size (Father or Father Figure)"
    case TShirtSizeSon = "T Shirt Size (Son)"
    case FatherBirthdate = "Father's Birthdate"
    case SonBirthdate = "Son's Birthdate"
    case EmergencyContactName = "Emergency Contact (not attending camp) (Combined)"
    case EmergencyContactFirstName = "Emergency Contact (not attending camp) (First)"
    case EmergencyContactLastName = "Emergency Contact (not attending camp) (Last)"
    case EmergencyContactPhoneNumber = "Emergency Contact Phone Number"
    case FatherMaritalStatus = "Father's marital status?"
    case KidsAges = "What are the ages of Father's kid(s)? (check all that apply...even those not attending this camp)"
    case ConnectedToChurch = "Are you connected to a church?"
    case Church = "What church are you connected with?"
    case CrossroadsSite = "If Crossroads is your church which site do you associate with?"
    case OpenMeetUps = "After camp are you open to having ongoing meet ups with others from camp?"
    case OpenToOrganizingMeetUps = "After Camp are you open to organizing ongoing meet ups with others from camp?"
    case FatherInCrossroadsGroup = "Is the Father currently in a Crossroads group of any kind?"
    case SonAgeAtCamp = "How old will the son be while at Father Son Camp?"
    case GroupingPrioritization = "How should we prioritize grouping you?"
    case Father1PreferenceFirstName = "Father 1 Preference (First)"
    case Father1PreferenceLastName = "Father 1 Preference (Last)"
    case Son1PreferenceFirstName = "Son 1 Preference (First)"
    case Son1PreferenceLastName = "Son 1 Preference (Last)"
    case Father2PreferenceFirstName = "Father 2 Preference (First)"
    case Father2PreferenceLastName = "Father 2 Preference (Last)"
    case Son2PreferenceFirstName = "Son 2 Preference (First)"
    case Son2PreferenceLastName = "Son 2 Preference (Last)"
    case FatherEthnicity = "FATHER'S race/ethnicity (check all that apply)"
    case FatherEthnicityOther = "other (additional details)"
    case SonEthnicity = "SON'S race/ethnicity (check all that apply)"
    case SonEthnicityOther = "Other (provide more details)"
    case FatherAttendedThisCampBefore = "Has the father attended this camp before?"
    case Was2023TheFirstYearAttending = "Was 2023 the first year attending?"
    case FatherHasAttendedOtherCamps = "Has the father ever attended any other Crossroads Camp(s)?"
    case FatherOtherAttendedCamps = "What other Crossroads Camps has the father attended before? (check all that apply)"
    case HowDidYouHear = "How did you hear about this camp?"
    case WhereDidYouHear = "Where did you hear about camp?"
    case RelationshipStrFatherAndSon = "How strong is the relationship between father and son? (0 in crisis 10 thriving)"
    case RelationshipWithGod = "How strong is the father's relationship with God & Jesus today? (0 - Nonexistent /not relevant 10 - very strong)"
    case TopReasonForAttending = "What is the top reason for attending this camp?"
    case OtherTopReasonForAttending = "Other (provide more information)"
    case IPromiseAgreement = "I accept the I Promise Agreement"
    case IPromiseAgreementNonLegalGuardian = "Do you accept the I Promise Agreement (non legal guardian)"
    case IPromiseAgreementPrayerVolunteer = "Do you accept the I Promise Agreement (single prayer volunteer)"
    case PhotoTermsAgreement = "I understand and agree to the Terms of the Photo Release and Authorization Agreement."
    case PurchaseTermsAgreement = "I understand and agree to the Terms of Purchase"
    case CampWaiverAgreement = "Do you accept the conditions of the Father Son Camp Waiver?"
    case NoRefundsOrTransfersUnderstanding = "I understand that there are no refunds or transfers of this purchase"
    case BackgroundCheck = "Background Check"
    case WaiverSigned = "Waiver Signed?"
    case GroupNumber = "Group Number"
    case GroupId = "Group Id"
    case GroupName = "Group Name"
    case GroupType = "Group Type"
    case GroupEmail = "Group Email"
    case GroupAttendeeCount = "Group Attendee Count"
    case SelectAgeYourSonAtCamp = "Please select the age your son will be at Father Son Camp"
    case EventNumber = "Event Number"
    case EventTitle = "Event Title"
    case EventLocationAddress = "Event Location Address"
    case EventLocationName = "Event Location Name"
    case EventOrganizerEmail = "Event Organizer Email"
    case EventOrganizerPhone = "Event Organizer Phone"
    case EventDateInfo = "Event Date Info"
    case EventClientKey = "Event Client Key"
    case EventURLKey = "Event URL Key"
    case OrderNumber = "Order Number"
    case OrderId = "Order Id"
    case OrderDate = "Order Date"
    case OrderAttendeeCount = "Order Attendee Count"
    case OrderCombinedName = "Order Name (Combined)"
    case OrderFirstName = "Order Name (First)"
    case OrderLastName = "Order Name (Last)"
    case OrderOrganization = "Order Organization"
    case OrderAddressCombined = "Order Address (Combined)"
    case OrderAddressStreet1 = "Order Address (Street1)"
    case OrderAddressStreet2 = "Order Address (Street2)"
    case OrderAddressCity = "Order Address (City)"
    case OrderAddressRegion = "Order Address (Region)"
    case OrderAddressRegionName = "Order Address (RegionName)"
    case OrderAddressPostalCode = "Order Address (PostalCode)"
    case OrderAddressCountry = "Order Address (Country)"
    case OrderAddressCountryName = "Order Address (CountryName)"
    case OrderPhone = "Order Phone"
    case OrderEmail = "Order Email"
    case OrderPaymentMethod = "Order Payment Method"
    case OrderDeliveryMethod = "Order Delivery Method"
    case OrderNotes = "Order Notes"
    case OrderViaKiosk = "Order Via Kiosk"
    case OrderViaAPI = "Order Via API"
    case OrderPlacedBy = "Order Placed By"
    case OrderUserName = "Order User Name"
    case CheckedInFriday = "Checked in @ Friday 4:30-6:00"
}

//"5bf064ac-ab7e-40b2-896f-181f853fa793","97251833","","Reserved","Father and Son - HQ","","$139.98","$139.98","$0.00","-$139.98","$0.00","$0.00","$0.00","$0.00","$0.00","1000FFAPTEST","-$139.98","True","False","False","","","False","3/31/2024 6:30:05 AM","","Yes","Bobberson, Bob","Bob","Bobberson","Bobberson, Jimbo","Jimbo","Bobberson","1234 Mcnabe Street, Florence, KY, 41042, US","1234 Mcnabe Street","","Florence","KY","41042","US","United States","Kentucky","(555) 555-5555","Sure","aaron.peck+campkings@crossroads.net","2XL","M","1984-10-30","2016-01-01","Peck, Amanda","Amanda","Peck","(555) 555-5555","Married","6-12 years of age, 13-17 years of age","Crossroads","","Florence","","Nope","Nope","8","","","","","","","","","","White","","White","","Attended multiple times before","","Nope","","Early Bird Promo","","1","4","A break from normal rhythms","","True","","","True","True","True","True","","","","","","","","","","574357","Copy of Father Son Camp 2024","420 Neville-Penn Schoolhouse Road, Felicity, OH 45120 United States","Crossroads Camp","fathersoncamp@crossroads.net","","Friday, May 31, 2024 4:00 PM - Sunday, Jun 2, 2024 1:00 PM EDT","campssb","camp","27779458E","8ebb349c-7057-4bc5-92af-b14400a0a271","3/31/2024 6:25:25 AM","13","Bobberson, Bob","Bob","Bobberson","","1234 Mcnabe Street, Florence, KY 41042 US","1234 Mcnabe Street","","Florence","KY","Kentucky","41042","US","United States","(555) 555-5555","aaron.peck+campkings@crossroads.net","No Charge","Email Confirmation","","False","False","Admin","peck, aaron",""
