//
//  ViewController.swift
//  iConFinder
//

import UIKit

final class ViewController: UIViewController {
    init(diContainer: DIContainer) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}
