//
//  SwagParserTests.swift
//  SwagTests
//
//  Created by Jianing Wang on 4/1/24.
//

import XCTest
import SwagCore

final class SwagParserTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testLEB128() throws {
        let uNumbers: [UInt64] = [0, 1, 127, 128, 255, 256, 16383, 16384, 2097151, 2097152, 268435455, 268435456, 34359738367, 34359738368, 4398046511103, 4398046511104, 562949953421311, 562949953421312, 72057594037927935, 72057594037927936, 9223372036854775807]
        for n in uNumbers {
            let bytes = encodeVarUInt(n)
            let (v, _) = try decodeVarUInt(data: bytes, size: 64)
            XCTAssertEqual(n, v)
        }
        
        
        let sNumbers: [Int64] = [-1234123, -548393486, -7543882, -123987518923645, -58596, -8754, -64, -63, -1, 0, 1, 63, 64, 8191, 8192, 1048575, 1048576, 134217727, 134217728, 17179869183, 17179869184, 2199023255551, 2199023255552, 281474976710655, 281474976710656, 36028797018963967, 36028797018963968, 4611686018427387903, 4611686018427387904, 9223372036854775807]
        for n in sNumbers {
            let bytes = encodeVarInt(n)
            let (v, _) = try decodeVarInt(data: bytes, size: 64)
            XCTAssertEqual(n, v)
        }
    }
    
    func testSnapshotMemory() throws {
        let datas: [[Byte?]] = [
            [0, 1, 2, nil, nil, nil, 3, 4, 5],
            [0, 1, 2, 3, 211, 123, 89, 49, 65, 91, 67],
            [0, 1, 2, 3, 211, 123, 89, 49, 65, 91, 67, nil, nil, nil],
        ]
        for data in datas {
            let memory = Memory(type: MemType(tag: .minMax, min: 1, max: 2), data: data)
            let snapshot = Snapshot(memory: memory)
            let snapshotData = snapshot.export()
            print(snapshotData)
            
            var reader = Reader(data: snapshotData)
            let snap = try reader.readSnapshot()
            XCTAssertEqual(memory, snap.memory)
        }
    }
    
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
