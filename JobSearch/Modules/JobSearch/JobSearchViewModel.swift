//
//  JobSearchViewModel.swift
//  JobSearch
//
//  Created by Kirill Vasilyev on 12.11.2023.
//

import UIKit

class JobSearchViewModel {
    
    // MARK: - Properties
    private var jobs: [Job] = []
    private var currentPage: Int = 0
    private var currentQuery: String = ""
    private let jobsPerPage: Int = 20
    var isFetching = false
    private let jobsQueue = DispatchQueue(label: "com.JobSearch.jobsQueue")

    // MARK: - Computed Properties
    var numberOfJobs: Int {
        return jobs.count
    }

    // MARK: - Public Methods
    // Returns a view model for a specific job at a given index
    func viewModelForJob(at index: Int) -> JobViewModel {
        return JobViewModel(job: jobs[index])
    }

    // Fetches jobs from the API
    func fetchJobsFromAPI(query: String, completion: @escaping () -> Void) {
        // Check if data is already being fetched
        if isFetching == true { return }

        isFetching = true

        // Update current query and reset data if the query has changed
        if currentQuery != query {
            currentQuery = query
            currentPage = 1
            jobsQueue.async(flags: .barrier) { self.jobs = [] }
        } else {
            // Increment page number to load more data
            currentPage += 1
        }

        // Construct the URL for the request
        let baseURL = "https://api.hh.ru/vacancies"
        let queryItems = [
            URLQueryItem(name: "text", value: query),
            URLQueryItem(name: "page", value: "\(currentPage)"),
            URLQueryItem(name: "per_page", value: "\(jobsPerPage)")
        ]
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.queryItems = queryItems

        // Validate URL
        guard let url = urlComponents?.url else {
            print("Invalid URL")
            isFetching = false // Reset fetching flag as request is not sent
            return
        }

        // Create and send the request
        var request = URLRequest(url: url)
        request.addValue("api-test-agent", forHTTPHeaderField: "User-Agent")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in

            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                let newJobs = apiResponse.items.map { Job(apiJob: $0) }

                DispatchQueue.main.async {
                    // Update jobs list and reset fetching flag
                    if self?.currentPage == 1 {
                        self?.jobs = newJobs
                    } else {
                        self?.jobs.append(contentsOf: newJobs)
                    }
                    self?.isFetching = false
                    completion()
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        task.resume()
    }

    // Clears the list of jobs
    func clearJobs() {
        jobs = []
    }
}
