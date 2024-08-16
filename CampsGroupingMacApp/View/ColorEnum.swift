import SwiftUI

enum ColorEnum: String {
    case plain = "CellBackingPlain"
    case select = "CellBackingSelect"
    case flagged = "CellBackingFlagged"
}

extension Color {
    init(enum colorEnum: ColorEnum) {
        self.init(colorEnum.rawValue, bundle: .main)
    }
}
