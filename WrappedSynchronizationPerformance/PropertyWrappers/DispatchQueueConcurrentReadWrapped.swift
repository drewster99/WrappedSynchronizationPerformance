//
//  DispatchQueueConcurrentReadWrapped.swift
//  WrappedSynchronizationPerformance
//
//  Created by Andrew Benson on 5/5/20.
//  Copyright © 2020 Nuclear Cyborg Corp. All rights reserved.
//

import Foundation

@propertyWrapper public struct DispatchQueueConcurrentReadWrapped<Wrapped> {
    private let queue = DispatchQueue(label: "com.nuclearcyborg.DispatchQueueWrapped_\(UUID().uuidString)",
                                      attributes: .concurrent)

    private var _wrappedValue: Wrapped
    public var wrappedValue: Wrapped {
        get { queue.sync { _wrappedValue } }
        set { queue.sync(flags: .barrier) { _wrappedValue = newValue } }
    }

    public mutating func modify(_ closure: (Wrapped) -> Wrapped) {
        queue.sync(flags: .barrier) {
            _wrappedValue = closure(_wrappedValue)
        }
    }

    public init(wrappedValue: Wrapped) {
        self._wrappedValue = wrappedValue
    }
}
