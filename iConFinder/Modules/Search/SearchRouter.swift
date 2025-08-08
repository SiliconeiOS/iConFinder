//
//  SearchRouter.swift
//  iConFinder
//
import UIKit

protocol SearchRouterProtocol {
    func showMessage(title: String, message: String)
    func showError(message: String)
    func showLoading(_ isVisible: Bool)
}

final class SearchRouter: SearchRouterProtocol {
    
    private weak var viewController: UIViewController?
    private var activityIndicator: UIActivityIndicatorView?
    private var overlayView: UIView?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController?.present(alert, animated: true)
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        viewController?.present(alert, animated: true)
    }
    
    func showLoading(_ isVisible: Bool) {
        guard let view = viewController?.view else { return }

        if isVisible {
            if overlayView == nil {
                let overlay = UIView(frame: view.bounds)
                overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                let indicator = UIActivityIndicatorView(style: .large)
                indicator.color = .white
                indicator.center = overlay.center
                indicator.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
                
                overlay.addSubview(indicator)
                self.overlayView = overlay
                self.activityIndicator = indicator
            }
            
            if let overlayView = overlayView, overlayView.superview == nil {
                view.addSubview(overlayView)
                activityIndicator?.startAnimating()
            }
        } else {
            activityIndicator?.stopAnimating()
            overlayView?.removeFromSuperview()
        }
    }
}
