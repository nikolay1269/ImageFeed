//
//  UILabel+Font.swift
//  ImageFeed
//
//  Created by Nikolay on 12.08.2024.
//

import UIKit

extension UILabel {
  func setTextSpacingBy(value: Double) {
    if let textString = self.text {
      let attributedString = NSMutableAttributedString(string: textString)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: value, range: NSRange(location: 0, length: attributedString.length - 1))
      attributedText = attributedString
    }
  }
}
