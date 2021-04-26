//
//  UIBarButton+hide.swift
//  Snacktacular
//
//  Created by Brishti Saha on 4/26/21.
//

import UIKit

extension UIBarButtonItem {
    func hide() {
        self.isEnabled = false
        self.tintColor = .clear
    }
}
