//
//  String+Date.swift
//  ImageFeed
//
//  Created by Nikolay on 07.11.2024.
//

import Foundation

extension String {
    func dateFromString() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: self)
        return date
    }
}
