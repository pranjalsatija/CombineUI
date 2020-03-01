//
//  CUIControlPublisher.swift
//  CombineUI
//
//  Created by pranjal on 1/21/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

import Combine
import UIKit

public class CUIControlPublisher<C: SupportsTargetAction>: Publisher {
    public typealias Output = C
    public typealias Failure = Never
    
    let control: C
    let events: [UIControl.Event]
    
    init(control: C, events: [UIControl.Event]) {
        self.control = control
        self.events = events
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Output == S.Input, Failure == S.Failure {
        let subscription = CUIControlSubscription(control: control, events: events, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}
