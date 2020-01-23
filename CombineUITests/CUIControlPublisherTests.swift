//
//  CUIControlPublisherTests.swift
//  CombineUITests
//
//  Created by pranjal on 1/21/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

import Combine
import XCTest

@testable import CombineUI

class CUIControlPublisherTests: XCTestCase {
    var control: UIControl!
    var events: [UIControl.Event]!
    var publisher: CUIControlPublisher<UIControl>!
    
    override func setUp() {
        control = UIControl()
        events = [.touchUpInside]
        publisher = CUIControlPublisher(control: control, events: events)
    }
    
    func test_initSetsControlAndEvents() {
        XCTAssert(publisher.control === control)
        XCTAssert(publisher.events == events)
    }
    
    func test_receiveSubscriberSendsASubscription() {
        let exp = expectation(description: "the mock subscriber should receive a subscription")
        
        let mockSubscriber = MockSubscriber<UIControl, Never>(
            onReceiveSubscription: {(subscription) in
                exp.fulfill()
            }
        )
                
        publisher.receive(subscriber: mockSubscriber)
        waitForExpectations(timeout: .infinity)
    }
    
    func test_UIControlExtensionForSingleEvent() {
        publisher = control.publisher(for: .touchUpInside)
        
        XCTAssert(publisher.control === control)
        XCTAssert(publisher.events == [.touchUpInside])
    }
    
    func test_UIControlExtensionForMultipleEvents() {
        publisher = control.publisher(for: [.touchDown, .touchUpInside])
        
        XCTAssert(publisher.control === control)
        XCTAssert(publisher.events == [.touchDown, .touchUpInside])
    }
}
