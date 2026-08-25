//
//  Color.swift
//  Expat App
//
//  Created by Dominik Baki on 06.05.25.
//

import Foundation
import SwiftUI
import UIKit

extension Color {
    var isDark: Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return false
        }

        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue

        return luminance < 0.5
    }
}
