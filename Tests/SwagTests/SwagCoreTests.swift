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
    
    func instantiate(_ path: URL) throws -> VM {
        let data = try XCTUnwrap(NSData(contentsOf: path))
        var buffer = [Byte].init(repeating: 0, count: data.length)
        data.getBytes(&buffer, length: data.length)
        var reader = Reader(data: buffer)
        let module = try reader.readModule()
//        var dumper = Dumper(module: module)
//        dumper.dump()
        let vm = VM(module: module)
        return vm
    }
    
    func testInstructions() throws {
        try testNumberic()
        try testParametric()
    }
    
    func testNumberic() throws {
        let casePath = fixtures.appendingPathComponent("00_Instructions")
            .appendingPathComponent("NumericInstructions.wasm")
        let instance = try instantiate(casePath)
        instance.loop()
    }
    
    func testParametric() throws {
        let casePath = fixtures.appendingPathComponent("00_Instructions")
            .appendingPathComponent("ParametricInstructions.wasm")
        let instance = try instantiate(casePath)
        instance.loop()
    }
    
    func testHelloworld() throws {
        let casePath = fixtures.appendingPathComponent("01_HelloWorld")
            .appendingPathComponent("HelloWorld.wasm")
        let instance = try instantiate(casePath)
        instance.loop()
    }
    
    func testFibonacci() throws {
        let casePath = fixtures.appendingPathComponent("02_Fibonacci")
            .appendingPathComponent("Fibonacci.wasm")
        let instance = try instantiate(casePath)
        instance.loop()
    }
    
    // assert function is defined internally
    func testFactorial() throws {
        let casePath = fixtures.appendingPathComponent("03_Factorial")
            .appendingPathComponent("Factorial.wasm")
        let instance = try instantiate(casePath)
        instance.loop()
        print("🎉🎉🎉🎉🎉🎉")
    }
    
    // assert function is provided by VM
    func testFactorial2() throws {
        let casePath = fixtures.appendingPathComponent("03_Factorial")
            .appendingPathComponent("Factorial2.wasm")
        let instance = try instantiate(casePath)
        instance.loop()
    }
    
    func testMemory() throws {
        let casePath = fixtures.appendingPathComponent("04_Memory")
            .appendingPathComponent("Memory.wasm")
        let instance = try instantiate(casePath)
        instance.loop()
    }
    
    // This is to test indirect call
    func testCalc() throws {
        let casePath = fixtures.appendingPathComponent("05_Calc")
            .appendingPathComponent("Calc.wasm")
        let instance = try instantiate(casePath)
        instance.loop()
    }
    
    // This is to test trace
    func testTraceInt() throws {
        let casePath = fixtures.appendingPathComponent("06_Trace_Int")
            .appendingPathComponent("trace1_int.wasm")
        let instance = try instantiate(casePath)
        instance.loop()
    }
    
    func testTraceStr() throws {
        let casePath = fixtures.appendingPathComponent("06_Trace_Int")
            .appendingPathComponent("trace2_str.wasm")
        let instance = try instantiate(casePath)
        instance.loop()
    }
    
    func testTraceArray() throws {
        let casePath = fixtures.appendingPathComponent("06_Trace_Int")
            .appendingPathComponent("trace3_array.wasm")
        let instance = try instantiate(casePath)
        instance.loop()
    }
    
//    func testTraceStackBuffer() throws {
//        let casePath = fixtures.appendingPathComponent("06_Trace_Int")
//            .appendingPathComponent("trace4.wasm")
//        let instance = try instantiate(casePath)
//        instance.loop()
//    }
    
    func testMalloc1() throws {
        let casePath = fixtures.appendingPathComponent("Malloc")
            .appendingPathComponent("example1.wasm")
        let instance = try instantiate(casePath)
        instance.loop()
    }
    
    func testMalloc2() throws {
        let casePath = fixtures.appendingPathComponent("Malloc")
            .appendingPathComponent("example2.wasm")
        let instance = try instantiate(casePath)
        instance.loop()
    }
    
    func testMalloc3() throws {
        let casePath = fixtures.appendingPathComponent("Malloc")
            .appendingPathComponent("example3.wasm")
        let instance = try instantiate(casePath)
        let hookDict: [FuncIdx: String] = [
            8: "malloc",
            9: "free"
        ]
        instance.hookDict = hookDict
        instance.loop()
    }

    static var allTests = [
        ("testInstructions", testInstructions),
        ("testHelloworld", testHelloworld),
        ("testFibonacci", testFibonacci),
        ("testFactorial", testFactorial),
        ("testFactorial2", testFactorial2),
        ("testMemory", testMemory)
    ]
}
