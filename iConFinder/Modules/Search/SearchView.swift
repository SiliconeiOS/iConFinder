//
//  SearchView.swift
//  iConFinder
//

import UIKit

enum SearchView {
    enum State {
        case initial
        case loading
        case noResults(query: String)
        case error(message: String)
        case content

        var isTableViewVisible: Bool {
            switch self {
            case .content:
                return true
            default:
                return false
            }
        }
    }
    
    final class StateView: UIView {
        private let iconImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .secondaryLabel
            return imageView
        }()
        
        private let messageLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            label.numberOfLines = 0
            return label
        }()
        
        private let activityIndicator: UIActivityIndicatorView = {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.hidesWhenStopped = true
            return indicator
        }()
        
        init() {
            super.init(frame: .zero)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupViews() {
            let stackView = UIStackView(arrangedSubviews: [iconImageView, messageLabel, activityIndicator])
            stackView.axis = .vertical
            stackView.spacing = 16
            stackView.alignment = .center
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                iconImageView.widthAnchor.constraint(equalToConstant: 80),
                iconImageView.heightAnchor.constraint(equalToConstant: 80)
            ])
        }
        
        func configure(with state: State) {
            switch state {
            case .initial:
                iconImageView.image = UIImage(systemName: "magnifyingglass.circle")
                messageLabel.text = "Start by searching for an icon"
                iconImageView.isHidden = false
                messageLabel.isHidden = false
                activityIndicator.stopAnimating()
            case .loading:
                iconImageView.isHidden = true
                messageLabel.text = "Loading results..."
                messageLabel.isHidden = false
                activityIndicator.startAnimating()
            case .noResults(let query):
                iconImageView.image = UIImage(systemName: "questionmark.circle")
                messageLabel.text = "No icons found for '\(query)'"
                iconImageView.isHidden = false
                messageLabel.isHidden = false
                activityIndicator.stopAnimating()
            case .error(let message):
                iconImageView.image = UIImage(systemName: "xmark.octagon")
                messageLabel.text = message
                iconImageView.isHidden = false
                messageLabel.isHidden = false
                activityIndicator.stopAnimating()
            case .content:
                iconImageView.isHidden = true
                messageLabel.isHidden = true
                activityIndicator.stopAnimating()
            }
            self.isHidden = state.isTableViewVisible
        }
    }
}   
