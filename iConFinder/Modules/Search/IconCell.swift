//
//  IconCell.swift
//  iConFinder
//
//  Created by Иван Дроботов on 8/4/25.
//

import UIKit

final class IconCell: UITableViewCell {
    
    static let reuseIdentifier = "IconCell"
    
    // MARK: - Properties
    
    private var imageLoadTask: Cancellable?
    
    // MARK: - UI
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let sizeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let tagsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        iconImageView.image = nil
        sizeLabel.text = nil
        tagsLabel.text = nil
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Public Methods
    
    func configure(with viewModel: IconViewModel, imageLoader: @escaping (@escaping (Result<UIImage, ImageServiceError>) -> Void) -> Cancellable?)   {
        sizeLabel.text = viewModel.sizeText
        tagsLabel.text = viewModel.tagsText
        
        activityIndicator.startAnimating()
        
        imageLoadTask = imageLoader { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let image):
                    self?.iconImageView.image = image
                case .failure:
                    self?.iconImageView.image = UIImage(systemName: "photo") // Placeholder
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupLayout() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(tagsLabel)
        iconImageView.addSubview(activityIndicator)
        
        let textStackView = UIStackView(arrangedSubviews: [sizeLabel, tagsLabel])
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.alignment = .leading
        contentView.addSubview(textStackView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 100),
            iconImageView.heightAnchor.constraint(equalToConstant: 100),
            
            activityIndicator.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            
            textStackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}
