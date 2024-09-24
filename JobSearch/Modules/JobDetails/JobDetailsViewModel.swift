//
//  JobDetailsViewModel.swift
//  JobSearch
//
//  Created by Kirill Vasilyev on 15.11.2023.
//

import Foundation

final class JobDetailsViewModel {
    // Holds the ID for the job details
    var vacancyId: String?
    
    // Stores the detailed job data
    var detailedJob: DetailedJob?
    
    // Callback for when job data is loaded
    var dataLoaded: ((DetailedJob) -> Void)?

    // Fetches job details from the API
    func loadVacancyDetails() {
        guard let vacancyId = vacancyId else { return }

        let urlString = "https://api.hh.ru/vacancies/\(vacancyId)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }

            do {
                let detailedJob = try JSONDecoder().decode(DetailedJob.self, from: data)
                DispatchQueue.main.async {
                    self?.detailedJob = detailedJob
                    self?.dataLoaded?(detailedJob)
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
