//
//  MockSubscriber.swift
//  CombineUITests
//
//  Created by pranjal on 1/21/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

import Combine

class MockSubscriber<Input, Failure: Error>: Subscriber {
    typealias OnReceiveInput = (Input) -> Subscribers.Demand
    typealias OnReceiveSubscription = (Subscription) -> Void
    typealias OnReceiveCompletion = (Subscribers.Completion<Failure>) -> Void
    
    let combineIdentifier = CombineIdentifier()
    
    var onReceiveInput: OnReceiveInput
    var onReceiveSubscription: OnReceiveSubscription
    var onReceiveCompletion: OnReceiveCompletion
    
    init(
        onReceiveInput: @escaping OnReceiveInput = { _ in .unlimited },
        onReceiveSubscription: @escaping OnReceiveSubscription = { _ in },
        onReceiveCompletion: @escaping OnReceiveCompletion = { _ in }
    ) {
        self.onReceiveInput = onReceiveInput
        self.onReceiveSubscription = onReceiveSubscription
        self.onReceiveCompletion = onReceiveCompletion
    }
    
    func receive(_ input: Input) -> Subscribers.Demand { onReceiveInput(input) }
    func receive(subscription: Subscription) { onReceiveSubscription(subscription) }
    func receive(completion: Subscribers.Completion<Failure>) { onReceiveCompletion(completion) }
}
