import XCTest
import SwagCore

final class SwagCoreTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
    }
    
    override class func tearDown() {
        super.tearDown()
    }
    
    let fixtures = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Fixtures")
    
    func testDumper() throws {
        let helloWorld = fixtures.appendingPathComponent("01_HelloWorld")
            .appendingPathComponent("HelloWorld.wasm")
        let data = try XCTUnwrap(NSData(contentsOf: helloWorld))
        var buffer = [Byte].init(repeating: 0, count: data.length)
        data.getBytes(&buffer, length: data.length)
        var reader = Reader(data: buffer)
        let module = reader.readModule()
        var dumper = Dumper(module: module)
        dumper.dump()
    }
    
    func testFibonacci() throws {
        let helloWorld = fixtures.appendingPathComponent("02_Fibonacci")
            .appendingPathComponent("Fibonacci.wasm")
        let data = try XCTUnwrap(NSData(contentsOf: helloWorld))
        var buffer = [Byte].init(repeating: 0, count: data.length)
        data.getBytes(&buffer, length: data.length)
        var reader = Reader(data: buffer)
        let module = reader.readModule()
        var dumper = Dumper(module: module)
        dumper.dump()
        var vm = VM(module: module)
        vm.loop()
        print("🎉🎉🎉🎉🎉🎉")
    }
    
    static var allTests = [
        ("testDumper", testDumper),
        ("testFibonacci", testFibonacci)
    ]
}
