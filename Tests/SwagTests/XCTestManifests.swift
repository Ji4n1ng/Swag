import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SwagTests.allTests),
        testCase(SwagCoreTests.allTests),
    ]
}
#endif
