//
//  HomeViewController.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 23/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

protocol HomeViewProtocol: BaseViewProtocol {
    func changeLabelText(to text: String)
}

class HomeViewController: UIViewController, HomeViewProtocol {

    @IBOutlet weak var testLabel: UILabel!
    
    @Inject private var presenter: HomeViewPresenterProtocol
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attach(view: self)
        print("loaded")
    }

    @IBAction func buttonPressed(_ sender: Any) {
        presenter.handleButtonTap()
    }
    
    func changeLabelText(to text: String) {
        testLabel.text = text
        testLabel.pin(edges: .top(padding: 0), .leading(padding: 0))
    }

}

extension HomeViewController {
    static func create() -> HomeViewController {
        return DependencyLoader.instance.container.resolve(HomeViewProtocol.self) as! HomeViewController
    }
}
