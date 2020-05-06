//
//  PerformanceTest.swift
//  WrappedSynchronizationPerformance
//
//  Created by Andrew Benson on 5/4/20.
//  Copyright © 2020 Nuclear Cyborg Corp. All rights reserved.
//

import Foundation

let dataSize: Int = 1000
let dataIterations: Int = 10_000

let data = (0 ..< dataSize).map { (s) -> Double in
    Double(Int.random(in: -1000 ... 1000))
}

var correctFinalValue: Double = {
    var correct: Double = 0
    for _ in 0 ..< dataIterations {
        for number in data {
            correct += number
        }
    }

    return correct
}()

public protocol PerformanceTest: class {
    var value: Double { get set }
    func performUncontendedTestSet()
    func performContendedTestSet()
    func modify(_ closure: (Double) -> Double)
    init()
}

public extension PerformanceTest {

    func napThen(_ doThis: @escaping () -> Void) {
        first(napFor: Settings.delaySeconds, then: doThis)
    }

    func first(napFor delaySeconds: TimeInterval, then doThis: @escaping () -> Void) {
        let g = DispatchGroup()
        g.enter()
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + delaySeconds) {
            doThis()
            g.leave()
        }
        g.wait()
    }

    /// Runs uncontended tests
    func performUncontendedTestSet() {
        print("    \(String(describing: type(of: self))):")
        var t = DrewIntervalTimer()

        Settings.delaySeconds = 1.0
        napThen {
            // write test
            self.value = 0
            t.start()
            for _ in 0 ..< dataIterations {
                for number in data {
                    self.value += number
                }
            }
            t.stop("        Uncontended write")
        }

        napThen {
            // read test
            t.start()
            for _ in 0 ..< dataIterations {
                for _ in data {
                    _ = self.value
                }
            }
            t.stop("        Uncontended read")
        }

        napThen {
            // modify test
            self.value = 0
            t.start()
            for _ in 0 ..< dataIterations {
                for number in data {
                    self.modify {
                        $0 + number
                    }
                }
            }
            t.stop()
            print("        Uncontended modify: \(t.description) \(self.value == correctFinalValue ? "[ok]" : "[DATA CORRUPT]")\n")
        }
    }

    /// Runs concurrent tests
    func performContendedTestSet() {
        print("    \(String(describing: type(of: self))):")

        let g = DispatchGroup()
        var t = DrewIntervalTimer()
        let simoCount = 10

        Settings.delaySeconds = 30.0
        napThen {
            // Simo write test
            self.value = 0
            t.start()
            for _ in 0 ..< simoCount {
                g.enter()
                DispatchQueue.global(qos: .userInteractive).async {
                    for _ in 0 ..< dataIterations / simoCount {
                        for number in data {
                            self.value += number
                        }
                    }
                    g.leave()
                }
            }
            g.wait()
            t.stop()
            print("        Concurrent write: \(t.description)")
        }

        napThen {
            // Simo read test
            t.start()
            for _ in 0 ..< simoCount {
                g.enter()
                DispatchQueue.global(qos: .userInteractive).async {
                    for _ in 0 ..< dataIterations / simoCount {
                        for _ in data {
                            _ = self.value
                        }
                    }
                    g.leave()
                }
            }
            g.wait()
            t.stop("        Concurrent read")
        }

        napThen {
            // Simo modify test
            self.value = 0
            t.start()
            for _ in 0 ..< simoCount {
                g.enter()
                DispatchQueue.global(qos: .userInteractive).async {
                    for _ in 0 ..< dataIterations / simoCount {
                        for number in data {
                            self.modify { $0 + number }
                        }
                    }
                    g.leave()
                }
            }
            g.wait()
            t.stop()
            print("        Concurrent modify: \(t.description) \(self.value == correctFinalValue ? "[ok]" : "[DATA CORRUPT]")\n")
        }
    }
}
