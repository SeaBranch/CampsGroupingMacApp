import Foundation

enum CampsScope: String, Equatable, HashID, Codable, CaseIterable {
    case camps = "CAMPS"
    case manCamp = "MANCAMP"
    case sandbox = "SANDBOX"

    var token: String {
        switch self {
        case .camps: "dGI3YnE1Y2ozbm02Ym0ydDo="
        case .manCamp: "Z3AzcHAzd3E2dG41ZHA4eTo="
        case .sandbox: "ZGs0bXY2aGg1cW01d2I5eTo="
        }
    }
}

/**

 export const manCampToken = "Z3AzcHAzd3E2dG41ZHA4eTo=";
 export const campsToken = "dGI3YnE1Y2ozbm02Ym0ydDo=";
 export const sandBoxToken = "ZGs0bXY2aGg1cW01d2I5eTo=";
 */
