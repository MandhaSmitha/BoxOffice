//
//  UITableViewCell+Extension.swift
//  BoxOffice
//
//  Created by Smitha Mandha on 7/8/18.
//  Copyright © 2018 SmithaReddy. All rights reserved.
//

import UIKit

/**
 A generic protocol that can conformed to by classes that extensively use
 identifier values
 
 returns a String value of the name of the class
 */
protocol Identifiable  {
    static var identifier: String {get}
}
extension UITableViewCell: Identifiable {
    static var identifier: String { return String(describing: self) }
}
