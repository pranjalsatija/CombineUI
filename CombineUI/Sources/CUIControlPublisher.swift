//
//  CUIControlPublisher.swift
//  CombineUI
//
//  Created by pranjal on 1/21/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

import Combine
import UIKit

class CUIControlPublisher<C: UIControl>: Publisher {
    typealias Output = C
    typealias Failure = Never
    
    let control: C
    let events: [UIControl.Event]
    
    init(control: C, events: [UIControl.Event]) {
        self.control = control
        self.events = events
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Output == S.Input, Failure == S.Failure {
        let subscription = CUIControlSubscription(control: control, events: events, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

extension NSObjectProtocol where Self: UIControl {
    func publisher(for events: [UIControl.Event]) -> CUIControlPublisher<Self> {
        return CUIControlPublisher(control: self, events: events)
    }
    
    func publisher(for event: UIControl.Event) -> CUIControlPublisher<Self> {
        return CUIControlPublisher(control: self, events: [event])
    }
}
