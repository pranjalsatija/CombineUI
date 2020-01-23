//
//  CUIControlSubscription.swift
//  CombineUI
//
//  Created by pranjal on 1/21/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

import Combine
import UIKit

class CUIControlSubscription<C: UIControl, S: Subscriber>: Subscription where S.Input == C {
    var control: C?
    let events: [UIControl.Event]
    var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    var hasDemand: Bool {
        return (demand.max ?? 1) > 0
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
    
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }
    
    func cancel() {
        control = nil
        subscriber = nil
    }
}
