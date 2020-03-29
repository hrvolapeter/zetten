//
//  ZettenTests.swift
//  ZettenTests
//
//  Created by Peter Hrvola on 28/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import XCTest
import Firebase
@testable import Zetten

class ZettenTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testNoteListModelLoadPerformacne() throws {
        // This is an example of a performance test case.
        measure {
            let vm = NoteListViewModel()
            let expectation = self.expectation(description: "waiting validation")
            let handle = vm.$notes.dropFirst().sink { notes in
                expectation.fulfill()
            }
            vm.onAppear()
            wait(for: [expectation], timeout: 1)
        }
        
    }
    
    func testNoteListModelSearchPerformacne() throws {
        // This is an example of a performance test case.
        measure {
            let vm = NoteListViewModel()
            
            let expectation = self.expectation(description: "waiting validation")
            expectation.expectedFulfillmentCount = 2
            
            let handle = vm.$notes.dropFirst().sink { notes in
                expectation.fulfill()
            }
            vm.onAppear()
            DispatchQueue.global(qos: .background).async {
                sleep(1)
                vm.searchTerm = "Ad"
            }
            
            wait(for: [expectation], timeout: 2 )
        }
        
    }
    
}
