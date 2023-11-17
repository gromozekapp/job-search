//
//
//  JobViewModel.swift
//  JobSearch
//
//  Created by Kirill Vasilyev on 12.11.2023.
//

import Foundation

struct JobViewModel {
    let id: String
    let title: String
    let companyName: String
    let salary: String?
    let requirementsSnippet: String?
    let responsibilitiesSnippet: String?
    let logoURL: String?

    init(job: Job) {
        self.id = job.id
        self.title = job.title
        self.companyName = job.companyName
        self.salary = job.salary
        self.logoURL = job.logoURL
        self.requirementsSnippet = job.requirementsSnippet?.strippingHTML()
        self.responsibilitiesSnippet = job.responsibilitiesSnippet?.strippingHTML()
    }
}
