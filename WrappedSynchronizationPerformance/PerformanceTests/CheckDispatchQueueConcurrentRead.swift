//
//  CheckDispatchQueueConcurrentRead.swift
//  WrappedSynchronizationPerformance
//
//  Created by Andrew Benson on 5/5/20.
//  Copyright © 2020 Nuclear Cyborg Corp. All rights reserved.
//

import Foundation

public class CheckDispatchQueueConcurrentRead: PerformanceTest {
    @DispatchQueueConcurrentReadWrapped public var value: Double = 0

    public func modify(_ closure: (Double) -> Double) {
        _value.modify(closure)
    }

    public required init() { }
}
