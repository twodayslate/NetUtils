import Combine
import JavaScriptCore
import SwiftUI

class JavaScriptInfoModel: DeviceInfoSectionModel {
    override init() {
        super.init()
        title = "JavaScriptCore Information"

        Task { @MainActor in
            reload()
        }
    }

    @MainActor override func reload() {
        enabled = true
        rows.removeAll()

        guard let context = JSContext() else {
            return
        }

        if let pi = context.evaluateScript("Math.PI"), pi.isNumber {
            rows.append(.row(title: "PI", content: "\(pi.toDouble())"))
        }

        if let value = context.evaluateScript("Math.E"), value.isNumber {
            rows.append(.row(title: "Euler's constant", content: "\(value.toDouble())"))
        }

        if let value = context.evaluateScript("Math.random()"), value.isNumber {
            rows.append(.row(title: "Random", content: "\(value.toDouble())"))
        }

        if let value = context.evaluateScript("Math.log(2)"), value.isNumber {
            rows.append(.row(title: "Natural log of 2", content: "\(value.toDouble())"))
        }

        if let value = context.evaluateScript("Math.log(10)"), value.isNumber {
            rows.append(.row(title: "Natural log of 10", content: "\(value.toDouble())"))
        }

        if let value = context.evaluateScript("Math.log2(10)"), value.isNumber {
            rows.append(.row(title: "Base 2 logarithm of 10", content: "\(value.toDouble())"))
        }

        if let value = context.evaluateScript("Math.log2(Math.E)"), value.isNumber {
            rows.append(.row(title: "Base 2 logarithm of E", content: "\(value.toDouble())"))
        }

        if let value = context.evaluateScript("Math.sqrt(2)"), value.isNumber {
            rows.append(.row(title: "Square root of 2", content: "\(value.toDouble())"))
        }

        if let value = context.evaluateScript("Math.sqrt(1/2)"), value.isNumber {
            rows.append(.row(title: "Square root of 1/2", content: "\(value.toDouble())"))
        }

        if let value = context.evaluateScript("Number.MAX_SAFE_INTEGER"), value.isNumber, let str = value.toNumber()?.stringValue {
            rows.append(.row(title: "Maxmimum Safe Integer", content: str))
        }

        if let value = context.evaluateScript("Number.MIN_SAFE_INTEGER"), value.isNumber, let str = value.toNumber()?.stringValue {
            rows.append(.row(title: "Minimum Safe Integer", content: str))
        }

        if let value = context.evaluateScript("Number.EPSILON"), value.isNumber, let str = value.toNumber()?.stringValue {
            rows.append(.row(title: "Epsilon", content: str))
        }

        if let value = context.evaluateScript("Number.MAX_VALUE"), value.isNumber {
            rows.append(.row(title: "Maximum Value", content: "\(value.toDouble())"))
        }

        if let value = context.evaluateScript("Number.MIN_VALUE"), value.isNumber {
            rows.append(.row(title: "Minimum Value", content: "\(value.toDouble())"))
        }
    }
}
