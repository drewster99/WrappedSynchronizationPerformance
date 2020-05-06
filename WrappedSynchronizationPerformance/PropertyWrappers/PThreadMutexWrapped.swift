//
//  PThreadMutexWrapped.swift
//  WrappedSynchronizationPerformance
//
//  Created by Andrew Benson on 5/5/20.
//  Copyright © 2020 Nuclear Cyborg Corp. All rights reserved.
//

import Foundation

@propertyWrapper public struct PThreadMutexWrapped<Wrapped> {
    private var lock = pthread_rwlock_t()

    private var _wrappedValue: Wrapped
    public var wrappedValue: Wrapped {
        mutating get {
            pthread_rwlock_rdlock(&lock)
            let result = _wrappedValue
            pthread_rwlock_unlock(&lock)
            return result
        }
        set {
            pthread_rwlock_wrlock(&lock)
            _wrappedValue = newValue
            pthread_rwlock_unlock(&lock)
        }
    }

    public mutating func modify(_ closure: (Wrapped) -> Wrapped) {
        pthread_rwlock_wrlock(&lock)
        _wrappedValue = closure(_wrappedValue)
        pthread_rwlock_unlock(&lock)
    }

    public init(wrappedValue: Wrapped) {
        self._wrappedValue = wrappedValue
        pthread_rwlock_init(&lock, nil)
    }
}
