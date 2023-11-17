//
//  JobDetailsViewController.swift
//  JobSearch
//
//  Created by Kirill Vasilyev on 15.11.2023.

import UIKit

class JobDetailsViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel = JobDetailsViewModel()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    // MARK: - UI Components
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let salaryLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 17)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        setupViewModel()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(salaryLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(addressLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.8)
        ])
    }

    private func setupViewModel() {
        viewModel.dataLoaded = { [weak self] detailedJob in
            self?.updateUI(with: detailedJob)
        }
        viewModel.loadVacancyDetails()
    }

    // MARK: - UI Update
    private func updateUI(with detailedJob: DetailedJob) {
        titleLabel.text = detailedJob.name
        descriptionLabel.text = detailedJob.description.strippingHTML()

        if let salary = detailedJob.salary {
            var salaryText = ""
            
            if let from = salary.from, let to = salary.to {
                salaryText = "\(from) – \(to)"
            } else if let from = salary.from {
                salaryText = "от \(from)"
            } else if let to = salary.to {
                salaryText = "до \(to)"
            }

            if let currency = salary.currency {
                salaryText += " \(currency)"
            }

            salaryLabel.text = salaryText
            salaryLabel.isHidden = salaryText.isEmpty
        } else {
            salaryLabel.isHidden = true
        }

        if let address = detailedJob.address, !address.city.isEmpty, !address.street.isEmpty, !address.building.isEmpty {
            addressLabel.text = "\(address.city), \(address.street), \(address.building)"
            addressLabel.isHidden = false
        } else {
            addressLabel.isHidden = true
        }
    }
}
