//
//  CUIViewControllerTests.swift
//  CombineUITests
//
//  Created by pranjal on 1/22/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

import Combine
import XCTest

@testable import CombineUI

class CUIViewControllerTests: XCTestCase {
    var exp: XCTestExpectation?
    var viewController: CUIViewController?
    var cancellable: AnyCancellable!
    
    override func setUp() {
        viewController = CUIViewController()
        cancellable = AnyCancellable {
            self.exp?.fulfill()
        }
    }
    
    func test_viewDidLoadCallsConfigureBindings() {
        let viewController = MockCUIViewController()
        viewController.viewDidLoad()
        
        XCTAssert(viewController.didCallConfigureBindings)
    }
    
    func test_cancellablesAreCancelledOnDeinit() {
        exp = expectation(description: "the cancellable is cancelled when the view controller deinits")
        
        viewController?.cancellables.insert(cancellable)
        viewController = nil
        
        waitForExpectations(timeout: .infinity)
    }
    
    func test_keyedCancellablesAreCancelledOnDeinit() {
        exp = expectation(description: "the keyed cancellable is cancelled when the view controller deinits")
        
        viewController?.keep(cancellable, aliveUsing: "test key")
        viewController = nil
        
        waitForExpectations(timeout: .infinity)
    }
    
    func test_keyedCancellablesAreCancelledOnReplacement() {
        exp = expectation(description: "the keyed cancellable is cancelled when it's replaced")
        
        viewController?.keep(cancellable, aliveUsing: "test key")
        viewController?.keep(AnyCancellable { }, aliveUsing: "test key")
        
        waitForExpectations(timeout: .infinity)
    }
}
