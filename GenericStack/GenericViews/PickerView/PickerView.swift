//
//  PickerView.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 20/07/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

protocol PickerViewDelegate: class {
    func pickerView(_ pickerView: PickerView, didSelectItem item: PickerRepresentable)
}

final class PickerView: NSObject {
    
    private var items: [PickerRepresentable] = []
    
    weak var delegate: PickerViewDelegate?
    
    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    func setItems(_ items: [PickerRepresentable]) {
        self.items = items
        pickerView.reloadAllComponents()
    }
    
    func selectRow(_ row: Int, inComponent component: Int, animated: Bool) {
        pickerView.selectRow(row, inComponent: component, animated: animated)
    }
    
    func setAsInputView(to textField: UITextField) {
        textField.inputView = pickerView
    }
    
}

extension PickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row].rowTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.pickerView(self, didSelectItem: items[row])
    }
}

