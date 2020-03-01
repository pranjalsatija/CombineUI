//
//  CUIControlSubscription.swift
//  CombineUI
//
//  Created by pranjal on 1/21/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

import Combine
import UIKit

public protocol SupportsTargetAction {
    func addTarget(_ target: Any?, action: Selector, for event: UIControl.Event)
}

public extension SupportsTargetAction {
    func publisher(for events: [UIControl.Event], shouldIgnoreDemand: Bool = true) -> CUIControlPublisher<Self> {
        return CUIControlPublisher(control: self, events: events)
    }
    
    func publisher(for event: UIControl.Event, shouldIgnoreDemand: Bool = true) -> CUIControlPublisher<Self> {
        return CUIControlPublisher(control: self, events: [event])
    }
}

extension UIBarButtonItem: SupportsTargetAction {
    public func addTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        self.action = action
        self.target = target as AnyObject
    }
}

extension UIControl: SupportsTargetAction { }

public class CUIControlSubscription<C: SupportsTargetAction, S: Subscriber>: Subscription where S.Input == C {
    var control: C?
    let events: [UIControl.Event]
    var subscriber: S?
    
    var demand: Subscribers.Demand = .unlimited
    
    var hasDemand: Bool {
        // TODO: find out why `demand != .none` doesn't work
        true
    }
    
    init(control: C, events: [UIControl.Event], subscriber: S) {
        self.control = control
        self.events = events
        self.subscriber = subscriber
        
        events.forEach {
            control.addTarget(self, action: #selector(eventReceived), for: $0)
        }
    }
    
    @objc func eventReceived() {
        guard let control = control, let subscriber = subscriber, hasDemand else { return }
        request(subscriber.receive(control))
    }
    
    public func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }
    
    public func cancel() {
        control = nil
        subscriber = nil
    }
}
