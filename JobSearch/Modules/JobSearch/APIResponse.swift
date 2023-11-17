//
//  APIResponse.swift
//  JobSearch
//
//  Created by Kirill Vasilyev on 12.11.2023.
//

import Foundation

// Structs for decoding API response
struct APIResponse: Codable {
    let items: [APIJob]
}

struct APIJob: Codable {
    let id: String
    let name: String
    let salary: APISalary?
    let employer: APIEmployer
    let snippet: APISnippet?
}

struct APISalary: Codable {
    let from: Int?
    let to: Int?
    let currency: String?
    let gross: Bool?
}

struct APIEmployer: Codable {
    let name: String
    let logo_urls: APILogoURLs?
}

struct APILogoURLs: Codable {
    let original: String?
    let medium: String?
    let small: String?
    
    enum CodingKeys: String, CodingKey {
        case original
        case medium = "240"
        case small = "90"
    }
}

struct APISnippet: Codable {
    let requirement: String?
    let responsibility: String?
}
