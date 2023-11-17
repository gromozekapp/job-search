//
//  String+strippingHTML.swift
//  JobSearch
//
//  Created by Kirill Vasilyev on 12.11.2023.
//

import Foundation

// Extension for string to strip HTML tags
extension String {
    func strippingHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
