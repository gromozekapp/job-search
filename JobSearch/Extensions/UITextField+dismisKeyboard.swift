//
//  UITextField+dismisKeyboard.swift
//  JobSearch
//
//  Created by Daniil Zolotarev on 20.09.24.
//

import UIKit

// MARK: delegate for hiden keyboard after press enter on mobil keyboard

extension UITextField: UITextFieldDelegate {
    func setupReturnKeyToDismiss() {
        self.delegate = self
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        return true
    }
}
