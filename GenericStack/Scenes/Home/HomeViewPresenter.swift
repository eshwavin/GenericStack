//
//  HomeViewPresenter.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 23/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

protocol HomeViewPresenterProtocol {
    func attach(view: HomeViewProtocol)
    func handleButtonTap()
}

class HomeViewPresenter: HomeViewPresenterProtocol {
    
    private weak var view: HomeViewProtocol?
    
    func attach(view: HomeViewProtocol) {
        self.view = view
    }
    
    func handleButtonTap() {
        view?.changeLabelText(to: "Button tapped")
    }
    
}
