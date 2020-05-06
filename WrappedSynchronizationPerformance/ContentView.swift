//
//  ContentView.swift
//  WrappedSynchronizationPerformance
//
//  Created by Andrew Benson on 5/3/20.
//  Copyright © 2020 Nuclear Cyborg Corp. All rights reserved.
//

import Foundation
import SwiftUI

struct TestDescription: Identifiable {
    let name: String
    let testType: PerformanceTest.Type

    var id: String { name }
}

struct ContentView: View {
    @State private var testType = 0

    let testDescriptions: [TestDescription] = [
        TestDescription(name: "Do Nothing", testType: CheckDoNothing.self),
        TestDescription(name: "DispatchQueue", testType: CheckDispatchQueue.self),
        TestDescription(name: "DispatchQueueConcurrentRead", testType: CheckDispatchQueueConcurrentRead.self),
        TestDescription(name: "DispatchSemaphore", testType: CheckDispatchSemaphore.self),
        TestDescription(name: "OSUnfairLock", testType: CheckOSUnfairLock.self),
        TestDescription(name: "PThreadMutex", testType: CheckPThreadMutex.self),
    ]

    var body: some View {
        VStack(spacing: 45.0) {

            VStack(alignment: .leading) {
                Button(action: {
                    let allTestInstances: [PerformanceTest] = self.testDescriptions.map { $0.testType.init() }

                    UIApplication.shared.isIdleTimerDisabled = true
                    print("Single-threaded tests...")
                    for test in allTestInstances {
                        test.performUncontendedTestSet()
                    }

                    print("Concurrent tests...")
                    for test in allTestInstances {
                        test.performContendedTestSet()
                    }
                    UIApplication.shared.isIdleTimerDisabled = false
                }) {
                    Text("Run All Tests")
                }
            }

            Picker(selection: $testType, label: Text("Choose Concurrency")) {
                Text("Single-threaded").tag(0)
                Text("Concurrent").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())

            VStack(alignment: .leading) {
                ForEach(testDescriptions) { test in
                    Button(action: {
                        let c = test.testType.init()
                        UIApplication.shared.isIdleTimerDisabled = true
                        if self.testType == 0 {
                            c.performUncontendedTestSet()
                        } else {
                            c.performContendedTestSet()
                        }
                        UIApplication.shared.isIdleTimerDisabled = false

                    }) {
                        Text("\(test.name) Test")
                    }
                }
            }
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
