//
//  File.swift
//  
//
//  Created by Emil Pedersen on 05/05/2021.
//

import UIKit

#if os(watchOS)
// watchOS-only, as we have none of these available. All are dark mode only as there's no light mode on there

extension UIColor {
    static let systemRed = UIColor(red: 1, green: 0.27, blue: 0.23, alpha: 1)
    static let systemGray2 = UIColor(red: 0.39, green: 0.39, blue: 0.40, alpha: 1)
    static let systemGray3 = UIColor(red: 0.72, green: 0.72, blue: 0.74, alpha: 1)
    static let label = UIColor.white
    static let secondarySystemBackground = UIColor(red: 0.28, green: 0.28, blue: 0.30, alpha: 1)
    static let secondaryLabel = UIColor(red: 0.92, green: 0.92, blue: 0.96, alpha: 0.6)
}
#endif

public extension UIColor {
    static let _markdownSpecifierForeground = UIColor.secondaryLabel
}
