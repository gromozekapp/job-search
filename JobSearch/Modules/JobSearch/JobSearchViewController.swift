//
// ViewController.swift
// JobSearch
//
// Created by Kirill Vasilyev on 11/12/2023.

import UIKit
import Combine

class JobSearchViewController: UIViewController {
    // MARK: - Properties
    private var searchTimer: Timer?
    private var viewModel = JobSearchViewModel()
    private var selectedIndexPath: IndexPath?
    
    private var searchTextFieldPublisher: AnyCancellable?
    private var searchQuery: String = ""
    
    // MARK: - UI Elements
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .lightGray.withAlphaComponent(0.3)
        textField.placeholder = "Должность, ключевые слова"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "Введите в поиск название, и появится список вакансий"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var jobsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(JobTableViewCell.self, forCellReuseIdentifier: "JobTableViewCell")
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 195
        tableView.rowHeight = UITableView.automaticDimension
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // for delegate dismisKeyboard
        searchTextField.setupReturnKeyToDismiss()
        
        setupViews()
        setupConstraints()
        view.backgroundColor = .white
        setupSearchTextFieldPublisher()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        view.addSubview(searchTextField)
        view.addSubview(jobsTableView)
        view.addSubview(noResultsLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noResultsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noResultsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            jobsTableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            jobsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            jobsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            jobsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // Function to set up Combine Publisher for the search text field
    private func setupSearchTextFieldPublisher() {
        searchTextFieldPublisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .map { ($0.object as? UITextField)?.text ?? "" }
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.handleSearchTextChange(query: query)
            }
    }
    
    // MARK: - Search Handling
    private func handleSearchTextChange(query: String) {
        searchQuery = query

        switch query.count {
        case 0:
            // Show a message when the search field is empty
            noResultsLabel.isHidden = false
            jobsTableView.isHidden = true
            viewModel.clearJobs()
            selectedIndexPath = nil
            jobsTableView.reloadData()
        case 1...2:
            // Hide the table view when there are less than 3 characters in the query
            noResultsLabel.isHidden = true
            jobsTableView.isHidden = true
            viewModel.clearJobs()
            selectedIndexPath = nil
            jobsTableView.reloadData()
        default:
            // Perform job search
            noResultsLabel.isHidden = true
            jobsTableView.isHidden = false
            performSearch(query: query)
        }
    }
    
    // Function to perform a job search
    private func performSearch(query: String) {
        viewModel.fetchJobsFromAPI(query: query) { [weak self] in
            self?.jobsTableView.reloadData()
            let hasData = self?.viewModel.numberOfJobs ?? 0 > 0
            self?.jobsTableView.isHidden = !hasData
        }
    }
}

    // MARK: - UITableViewDelegate
extension JobSearchViewController: UITableViewDelegate {
    // Table view delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfJobs
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle cell selection and navigation to job details
        if let selectedIndexPath = self.selectedIndexPath, selectedIndexPath != indexPath {
            if let selectedCell = tableView.cellForRow(at: selectedIndexPath) as? JobTableViewCell {
                selectedCell.containerView.backgroundColor = .white
            }
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? JobTableViewCell else { return }
        cell.selectionStyle = .none
        
        UIView.animate(withDuration: 0.2, animations: {
            cell.containerView.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                cell.containerView.transform = CGAffineTransform.identity
            }) { _ in
                let vacancyId = self.viewModel.viewModelForJob(at: indexPath.row).id
                let detailsVC = JobDetailsViewController()
                detailsVC.viewModel.vacancyId = vacancyId
                self.navigationController?.pushViewController(detailsVC, animated: true)
            }
        }
        
        cell.containerView.backgroundColor = .lightGray.withAlphaComponent(0.3)
        selectedIndexPath = indexPath
    }
}

    // MARK: - UITableViewDataSource
extension JobSearchViewController: UITableViewDataSource {
    // Table view data source methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "JobTableViewCell", for: indexPath) as? JobTableViewCell else {
            return UITableViewCell()
        }
        let jobViewModel = viewModel.viewModelForJob(at: indexPath.row)
        cell.configure(with: jobViewModel)
        cell.containerView.backgroundColor = (indexPath == selectedIndexPath) ? .lightGray.withAlphaComponent(0.3) : .white
        return cell
    }
}

    // MARK: - UITableViewDataSourcePrefetching
extension JobSearchViewController: UITableViewDataSourcePrefetching {
    // Table view data prefetching method
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let maxRow = indexPaths.map({ $0.row }).max() else { return }
        
        if maxRow >= viewModel.numberOfJobs - 5 && !viewModel.isFetching {
            guard let query = searchTextField.text, !query.isEmpty else {
                return
            }
            performSearch(query: query)
        }
    }
}
