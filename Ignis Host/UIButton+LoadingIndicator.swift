//
//  UIButton+LoadingIndicator.swift
//  Ignis Host
//
//  created by user DanielQ at StackOverFlow
//  http://stackoverflow.com/questions/15269264/place-a-uiactivityindicator-inside-a-uibutton
//

import Foundation
import UIKit

extension UIButton {
    func showLoading(show: Bool) {
        let tag = 1419
        if show {
            let indicator = UIActivityIndicatorView()
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            self.titleLabel?.isHidden = true
            indicator.center = CGPoint(x:buttonWidth/2, y:buttonHeight/2)
            indicator.tag = tag
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
                self.titleLabel?.isHidden = false
            }
        }
    }
}
