//
//  CUIViewController.swift
//  CombineUI
//
//  Created by pranjal on 1/22/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

import Combine
import UIKit

class CUIViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    var keyedCancellables = [AnyHashable : AnyCancellable]()
    
    deinit {
        cancellables.forEach { $0.cancel() }
        keyedCancellables.values.forEach { $0.cancel() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBindings()
    }
    
    func configureBindings() {
        
    }
    
    func keep(_ object: AnyCancellable, aliveUsing key: AnyHashable) {
        if let existingObject = keyedCancellables[key] {
            existingObject.cancel()
        }
        
        keyedCancellables[key] = object
    }
}
