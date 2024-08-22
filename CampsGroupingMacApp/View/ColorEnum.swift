import SwiftUI

enum ColorEnum: String {
    case plain = "CellBackingPlain"
    case select = "CellBackingSelect"
    case flagged = "CellBackingFlagged"
    case actionDetail = "ActionDetail"
    case positiveDetail = "PositiveDetail"
    case negativeDetail = "NegativeDetail"
    case warningDetail = "WarningDetail"
}

extension Color {
    init(enum colorEnum: ColorEnum) {
        self.init(colorEnum.rawValue, bundle: .main)
    }
}
