//  JobCell.swift
//  JobSearch
//
//  Created by Kirill Vasilyev on 12.11.2023.
//

import UIKit
import SDWebImage

final class JobTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    private var currentImageURL: URL?
    // properties for using custom colors from Asset Catalog
    private let label = UILabel()
    private let bgcustomColor = UIColor(named: "BGCustomColor")
    private let customColor = UIColor(named: "CustomColor")
    
    // MARK: - UI Components
    // Container view for cell content
    let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let companyLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let jobTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let salaryLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let companyNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let requirementsSnippetLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let responsibilitiesSnippetLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Setting a dynamic color for the backgroung
        contentView.backgroundColor = bgcustomColor
        // Setting a dynamic color for the text, which will be adapted depending on the topic
        label.textColor = customColor
       
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(companyLogoImageView)
        containerView.addSubview(infoStackView)
        infoStackView.addArrangedSubview(jobTitleLabel)
        infoStackView.addArrangedSubview(salaryLabel)
        infoStackView.addArrangedSubview(companyNameLabel)
        infoStackView.addArrangedSubview(requirementsSnippetLabel)
        infoStackView.addArrangedSubview(responsibilitiesSnippetLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            companyLogoImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            companyLogoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            companyLogoImageView.widthAnchor.constraint(equalToConstant: 100),
            companyLogoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            infoStackView.topAnchor.constraint(equalTo: companyLogoImageView.topAnchor),
            infoStackView.leadingAnchor.constraint(equalTo: companyLogoImageView.trailingAnchor, constant: 10),
            infoStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            infoStackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10)
        ])
    }

    // Prepare for cell reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        companyLogoImageView.image = UIImage(named: "placeholder")
        currentImageURL = nil
    }
    
    // MARK: - Cell Configuration
    func configure(with viewModel: JobViewModel) {
        jobTitleLabel.text = viewModel.title
        companyNameLabel.text = viewModel.companyName
        salaryLabel.text = viewModel.salary
        salaryLabel.isHidden = viewModel.salary == nil

        requirementsSnippetLabel.text = viewModel.requirementsSnippet
        responsibilitiesSnippetLabel.text = viewModel.responsibilitiesSnippet

        updateImage(with: viewModel.logoURL)
    }

    // MARK: - Image Handling
    private func updateImage(with logoURLString: String?) {
        guard let logoURLString = logoURLString, let url = URL(string: logoURLString), currentImageURL != url else {
            companyLogoImageView.image = UIImage(named: "placeholder")
            return
        }

        currentImageURL = url
        loadImage(from: url) { [weak self] image in
            DispatchQueue.main.async {
                if self?.currentImageURL == url {
                    self?.companyLogoImageView.image = image
                }
            }
        }
    }

    // Function to load image using SDWebImage
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        SDWebImageManager.shared.loadImage(
            with: url,
            options: [],
            progress: nil
        ) { image, _, _, _, _, _ in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
