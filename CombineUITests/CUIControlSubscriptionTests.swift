//
//  CUIControlSubscriptionTests.swift
//  CombineUITests
//
//  Created by pranjal on 1/21/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

import Combine
import XCTest

@testable import CombineUI

class CUIControlSubscriptionTests: XCTestCase {
    var control: UIControl!
    var events: [UIControl.Event]!
    var subscriber: MockSubscriber<UIControl, Never>!
    var subscriberWasNotified = false
    var subscription: CUIControlSubscription<UIControl, MockSubscriber<UIControl, Never>>!
    
    override func setUp() {
        control = UIControl()
        events = [.touchUpInside]
        subscriber = MockSubscriber(
            onReceiveInput: { _ in
                self.subscriberWasNotified = true
                return self.subscription.demand
            }
        )
        
        subscriberWasNotified = false
        subscription = CUIControlSubscription(control: control, events: events, subscriber: subscriber)
    }
    
    func test_hasDemandIsTrueForUnlimitedAndNonzeroDemands() {
        subscription.demand = .max(5)
        XCTAssert(subscription.hasDemand)
        
        subscription.demand = .unlimited
        XCTAssert(subscription.hasDemand)
    }
    
    func test_hasDemandIsFalseForZeroDemands() {
        subscription.demand = .max(0)
        XCTAssert(subscription.hasDemand == false)
    }
    
    func test_init() {
        XCTAssert(subscription.control === control)
        XCTAssert(subscription.events == events)
        XCTAssert(subscription.subscriber === subscriber)
        
        // ensure that the subscription is "listening" to the control
        // this is done by making sure the control has actions for which the subscription is the target
        XCTAssert(control.actions(forTarget: subscription, forControlEvent: events.first!) != nil)
    }
    
    func test_eventReceivedWithDemand() {
        subscription.demand = .unlimited
        subscription.eventReceived()
        XCTAssert(subscriberWasNotified)
    }
    
    func test_eventNotReceivedWithNoDemand() {
        subscription.demand = .none
        subscription.eventReceived()
        XCTAssert(!subscriberWasNotified)
    }
    
    func test_eventNotReceivedWhenControlIsNil() {
        subscription.control = nil
        subscription.eventReceived()
        XCTAssert(!subscriberWasNotified)
    }
    
    func test_request() {
        subscription.request(.none)
        XCTAssert(subscription.demand == .none)
        
        subscription.request(.unlimited)
        XCTAssert(subscription.demand == .unlimited)
        
        subscription.request(.max(5))
        XCTAssert(subscription.demand == .max(5))
    }
    
    func test_cancel() {
        XCTAssert(subscription.control != nil)
        XCTAssert(subscription.subscriber != nil)
        
        subscription.cancel()
        
        XCTAssert(subscription.control == nil)
        XCTAssert(subscription.subscriber == nil)
    }
}
