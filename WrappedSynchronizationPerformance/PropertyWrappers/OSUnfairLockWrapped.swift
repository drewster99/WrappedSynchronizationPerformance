//
//  OSUnfairLockWrapped.swift
//  WrappedSynchronizationPerformance
//
//  Created by Andrew Benson on 5/4/20.
//  Copyright © 2020 Nuclear Cyborg Corp. All rights reserved.
//

import Foundation

@propertyWrapper public struct OSUnfairLockWrapped<Wrapped> {
    private var lock = os_unfair_lock()

    private var _wrappedValue: Wrapped
    public var wrappedValue: Wrapped {
        mutating get {
            os_unfair_lock_lock(&lock)
            let result = _wrappedValue
            os_unfair_lock_unlock(&lock)
            return result
        }
        set {
            os_unfair_lock_lock(&lock)
            _wrappedValue = newValue
            os_unfair_lock_unlock(&lock)
        }
    }

    public mutating func modify(_ closure: (Wrapped) -> Wrapped) {
        os_unfair_lock_lock(&lock)
        _wrappedValue = closure(_wrappedValue)
        os_unfair_lock_unlock(&lock)
    }

    public init(wrappedValue: Wrapped) {
        self._wrappedValue = wrappedValue
    }
}
