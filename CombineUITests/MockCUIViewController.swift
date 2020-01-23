//
//  MockCUIViewController.swift
//  CombineUITests
//
//  Created by pranjal on 1/22/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

@testable import CombineUI

class MockCUIViewController: CUIViewController {
    var didCallConfigureBindings = false
    var didCallViewDidLoad = false
    
    override func viewDidLoad() {
        didCallViewDidLoad = true
        super.viewDidLoad()
    }
    
    override func configureBindings() {
        didCallConfigureBindings = true
        super.configureBindings()
    }
}
