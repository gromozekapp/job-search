//
//  DetailedJob.swift
//  JobSearch
//
//  Created by Kirill Vasilyev on 15.11.2023.
//

import Foundation

struct DetailedJob: Decodable {
    let id: String
    let name: String
    let salary: Salary?
    let description: String
    let address: Address?

    struct Salary: Decodable {
        let from: Int?
        let to: Int?
        let currency: String?
    }

    struct Address: Decodable {
        let city: String
        let street: String
        let building: String
    }
}
