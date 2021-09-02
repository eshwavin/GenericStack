//
//  BaseViewProtocol.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 21/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

protocol BaseViewProtocol: AnyObject {
    func showActivityIndicator(allowingUserInteraction: Bool)
    func hideActivityIndicator()
    func hideBackButtonTitle()
}

extension BaseViewProtocol where Self: UIViewController {
    
    func showActivityIndicator(allowingUserInteraction: Bool) {
        view.showActivityIndicator(allowingUserInteraction: allowingUserInteraction)
    }
    
    func hideActivityIndicator() {
        view.hideActivityIndicator()
    }
    
    func hideBackButtonTitle() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
