//
//  Utils.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 20.04.26.
//

import Foundation
import UIKit

struct Utils {
    
    @MainActor
    static func getTopViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        if let nav = controller as? UINavigationController {
            return getTopViewController(controller: nav.visibleViewController)
        } else if let tab = controller as? UITabBarController,
                  let selected = tab.selectedViewController {
            return getTopViewController(controller: selected)
        } else if let presented = controller?.presentedViewController {
            return getTopViewController(controller: presented)
        }
        return controller
    }
}
