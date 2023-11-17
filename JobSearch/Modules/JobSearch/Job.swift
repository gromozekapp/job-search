//
//  Job.swift
//  JobSearch
//
//  Created by Kirill Vasilyev on 12.11.2023.
//

import UIKit

struct Job {
    let id: String
    let title: String
    let salary: String?
    let companyName: String
    let logoURL: String?
    let requirementsSnippet: String?
    let responsibilitiesSnippet: String?
}

// Extension to map APIJob to Job
extension Job {
    init(apiJob: APIJob) {
        self.id = apiJob.id
        self.title = apiJob.name

        // Forming salary information
        if let salaryData = apiJob.salary {
            var salaryComponents = [String]()

            if let from = salaryData.from, let to = salaryData.to {
                // Both 'from' and 'to' values are present
                salaryComponents.append("\(from) – \(to)")
            } else if let from = salaryData.from {
                // Only 'from' value is present
                salaryComponents.append("\(from)")
            } else if let to = salaryData.to {
                // Only 'to' value is present
                salaryComponents.append("\(to)")
            }

            if !salaryComponents.isEmpty, let currency = salaryData.currency {
                salaryComponents.append(currency)
            }

            self.salary = salaryComponents.joined(separator: " ")

        } else {
            self.salary = nil // No salary information
        }

        self.companyName = apiJob.employer.name
        self.logoURL = apiJob.employer.logo_urls?.medium
        self.requirementsSnippet = apiJob.snippet?.requirement
        self.responsibilitiesSnippet = apiJob.snippet?.responsibility
    }
}
