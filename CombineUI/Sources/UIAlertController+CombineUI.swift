//
//  UIAlertController+CombineUI.swift
//  Fantastique
//
//  Created by pranjal on 2/29/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

import Combine

public extension UIAlertController {
    static func promptForText(
        title: String? = nil,
        message: String? = nil,
        placeholder: String? = nil,
        on viewController: UIViewController
    ) -> AnyPublisher<String?, Never> {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let subject = PassthroughSubject<String?, Never>()
        
        var didSendText = false
        func send(_ text: String?) {
            guard !didSendText else {
                return
            }
            
            subject.send(text)
            didSendText = true
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) {(_) in
            send(nil)
            alertController.dismiss(animated: true)
        })
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: "Add"), style: .default) {(_) in
            let text = alertController.textFields?.first?.text
            send(text)
            alertController.dismiss(animated: true)
        })
                
        alertController.addTextField {(textField) in
            textField.placeholder = placeholder
            
            let publisher = textField.publisher(for: .editingDidEnd)
                .map { $0.text }
                .sink {
                    send($0)
                    alertController.dismiss(animated: true)
                }
            
            textField.retain(publisher)
        }
        
        viewController.present(alertController, animated: true)
        return subject.eraseToAnyPublisher()
    }
}
