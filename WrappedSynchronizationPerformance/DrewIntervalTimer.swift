//
//  DrewIntervalTimer.swift
//  WrappedSynchronizationPerformance
//
//  Created by Andrew Benson on 5/4/20.
//  Copyright © 2020 Nuclear Cyborg Corp. All rights reserved.
//

// Don't judge this crappy code.  I know it sucks in many ways, but I am too lazy to fix it.

import Foundation

public struct DrewIntervalTimer {
    var begin: CFAbsoluteTime
    var end: CFAbsoluteTime
    var lapCount: Int
    var label: String
    var iterationsMode: Bool = false
    var aggregateTime: Double

    public init(_ label: String = "") {
        begin = CFAbsoluteTimeGetCurrent()
        end = 0
        lapCount = 0
        self.label = label
        iterationsMode = false
        aggregateTime = 0.0
    }
    public mutating func start() {
        begin = CFAbsoluteTimeGetCurrent()
        end = 0
        if !iterationsMode {
            lapCount = 0
        }
    }

    @discardableResult
    public mutating func stop() -> Double {
        if end == 0 {
            end = CFAbsoluteTimeGetCurrent()
            lapCount += 1
        }

        let interval = Double(end - begin)
        if iterationsMode {
            aggregateTime += interval
        }
        return interval
    }

    @discardableResult
    public mutating func stop(_ message: String = "") -> Double {
        let final = self.stop()
        let messageToUse = message.isEmpty ? label : message
        print("\(messageToUse): \(description)")
        return final
    }

    @discardableResult
    public mutating func lap() -> Double {
        lapCount += 1

        return Double(CFAbsoluteTimeGetCurrent() - begin)
    }

    public var duration: CFAbsoluteTime {
        get {
            if end == 0 {
                return CFAbsoluteTimeGetCurrent() - begin
            } else {
                return end - begin
            }
        }
        set {
            end = newValue
            begin = 0
        }
    }

    public func getFormattedDuration(_ duration: CFAbsoluteTime) -> String {
        let time = duration
        if time > 100 {
            return " \(String(format: "%.1f", time/60)) min"
        } else if time < 1e-6 {
            return " \(String(format: "%.1f", time*1e9)) ns"
        } else if time < 1e-3 {
            return " \(String(format: "%.1f", time*1e6)) µs"
        } else if time < 1 {
            return " \(String(format: "%.1f", time*1000)) ms"
        } else {
            return " \(String(format: "%.2f", time)) s"
        }
    }

    public mutating func getSummaryDescription() -> String {
        if iterationsMode {
            let averageTime = aggregateTime / Double(lapCount)

            let s = "\(label):\n  # Samples: \(lapCount)\n  Total time: \(getFormattedDuration(aggregateTime))\n  Average: \(getFormattedDuration(averageTime))\n"
            return(s)
        } else {
            let finishingTime = end != 0 ? end : CFAbsoluteTimeGetCurrent()
            let elapsedTime = finishingTime - begin
            let averageTime = elapsedTime / Double(lapCount)

            let s = "\(label):\n  # Samples: \(lapCount)\n  Total time: \(getFormattedDuration(elapsedTime))\n  Average: \(getFormattedDuration(averageTime))\n"
            return(s)
        }
    }
}

extension DrewIntervalTimer: CustomStringConvertible {
    public var description: String {
        return getFormattedDuration(duration)
    }
}
