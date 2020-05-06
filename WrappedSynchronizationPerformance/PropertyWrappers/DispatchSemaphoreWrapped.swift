//
//  DispatchSemaphoreWrapped.swift
//  WrappedSynchronizationPerformance
//
//  Created by Andrew Benson on 5/4/20.
//  Copyright © 2020 Nuclear Cyborg Corp. All rights reserved.
//

import Foundation

@propertyWrapper public struct DispatchSemaphoreWrapped<Wrapped> {
    private var sema = DispatchSemaphore(value: 1)

    private var _wrappedValue: Wrapped
    public var wrappedValue: Wrapped {
        get {
            sema.wait()
            let result = _wrappedValue
            sema.signal()
            return result
        }
        set {
            sema.wait()
            _wrappedValue = newValue
            sema.signal()
        }
    }

    public mutating func modify(_ closure: (Wrapped) -> Wrapped) {
        sema.wait()
        _wrappedValue = closure(_wrappedValue)
        sema.signal()
    }

    public init(wrappedValue: Wrapped) {
        self._wrappedValue = wrappedValue
    }
}
