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
    
    func instantiate(_ path: URL, isDump: Bool = false) throws -> VM {
        let data = try XCTUnwrap(NSData(contentsOf: path))
        var buffer = [Byte].init(repeating: 0, count: data.length)
        data.getBytes(&buffer, length: data.length)
        var reader = Reader(data: buffer)
        let module = try reader.readModule()
        var dumper = Dumper(module: module)
        if isDump {
            dumper.dump()
        }
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
        print(instance.executedInsCount)
    }
    
    func testControl2() throws {
        let casePath = fixtures.appendingPathComponent("Control_Ins")
            .appendingPathComponent("if2.wasm")
        let vm = try instantiate(casePath)
        vm.printInstr = true
        vm.partitionThreshold = 17
        vm.loop()
        print("Executed ins count: \(vm.executedInsCount)")
        
        let snapshot = Snapshot(memory: vm.memory, operandStack: vm.operandStack, controlStack: vm.controlStack)
        let url = URL(fileURLWithPath: "/Users/jianing/Desktop/if2.snapshot")
        snapshot.export(url)
        
        let snapshotData = try XCTUnwrap(NSData(contentsOf: url))
        var buf = [Byte].init(repeating: 0, count: snapshotData.length)
        snapshotData.getBytes(&buf, length: snapshotData.length)
        var reader = Reader(data: buf)
        let snapshot2 = try reader.readSnapshot(module: vm.module)
          
        // Restore the state of vm2 from snapshot1
        let vm2 = VM(module: vm.module)
        vm2.restore(from: snapshot2)
        vm2.loop()
        print("vm2 has executed \(vm2.executedInsCount) instructions")
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
    
    func testControl() throws {
        let casePath = fixtures.appendingPathComponent("Control_Ins")
            .appendingPathComponent("br.wasm")
        let instance = try instantiate(casePath)
        instance.loop()
    }
    
    func testSnapshot() throws {
        // Read WASM binary
        let dir = fixtures.appendingPathComponent("02_Fibonacci")
        let casePath = dir.appendingPathComponent("Fibonacci.wasm")
        let binaryData = try XCTUnwrap(NSData(contentsOf: casePath))
        var buffer = [Byte].init(repeating: 0, count: binaryData.length)
        binaryData.getBytes(&buffer, length: binaryData.length)
        var reader = Reader(data: buffer)
        let wasmModule = try reader.readModule()
        
        // Full execution
        let vm0 = VM(module: wasmModule)
        vm0.loop()
        print("vm0 has executed \(vm0.executedInsCount) instructions")

        // Partition the execution
        // vm1
        let vm1 = VM(module: wasmModule)
        vm1.partitionThreshold = 1234
        vm1.loop()
        print("vm1 has executed \(vm1.executedInsCount) instructions")
        
        // Export the state of vm1 to snapshot1
        let snapshot1 = Snapshot(
            memory: vm1.memory,
            operandStack: vm1.operandStack,
            controlStack: vm1.controlStack
        )
        let url1 = dir.appendingPathComponent("1.snapshot")
        snapshot1.export(url1)
        
        // Load the data of snapshot1
        let snapshotData1 = try XCTUnwrap(NSData(contentsOf: url1))
        var buf1 = [Byte].init(repeating: 0, count: snapshotData1.length)
        snapshotData1.getBytes(&buf1, length: snapshotData1.length)
        var reader1 = Reader(data: buf1)
        let snapshot2 = try reader1.readSnapshot(module: wasmModule)
          
        // Restore the state of vm2 from snapshot1
        let vm2 = VM(module: wasmModule)
        vm2.restore(from: snapshot2)
        vm2.loop()
        print("vm2 has executed \(vm2.executedInsCount) instructions")
    }
    

    static var allTests = [
        ("testInstructions", testInstructions),
        ("testHelloworld", testHelloworld),
        ("testFibonacci", testFibonacci),
        ("testFactorial", testFactorial),
        ("testFactorial2", testFactorial2),
        ("testMemory", testMemory),
    ]
}
