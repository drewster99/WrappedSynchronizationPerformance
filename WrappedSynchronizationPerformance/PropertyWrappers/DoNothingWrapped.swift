//
//  DoNothingWrapped.swift
//  WrappedSynchronizationPerformance
//
//  Created by Andrew Benson on 5/4/20.
//  Copyright © 2020 Nuclear Cyborg Corp. All rights reserved.
//

import Foundation

@propertyWrapper public struct DoNothingWrapped<Wrapped> {
    private var _wrappedValue: Wrapped
    public var wrappedValue: Wrapped {
        get { _wrappedValue }
        set { _wrappedValue = newValue }
    }

    public mutating func modify(_ closure: (Wrapped) -> Wrapped) {
        _wrappedValue = closure(_wrappedValue)
    }

    public init(wrappedValue: Wrapped) {
        self._wrappedValue = wrappedValue
    }
}
