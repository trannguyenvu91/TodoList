//
//  TodoListTests.swift
//  TodoListTests
//
//  Created by VuVince on 9/13/16.
//  Copyright © 2016 VuVince. All rights reserved.
//

import XCTest
@testable import TodoList

class TodoListTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let model = VTDataManager.defaultManager.insertOrUpdatetodoModel(withID: 9999)
        model.id = 999
        model.name = "Test"
        model.state = 1
        
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        VTDataManager.defaultManager.deleteAlltodoModels()
    }
    
    
    func testFetchedController() {
        let doneFC = VTDataManager.defaultManager.todoModelsFetchedController(ListType.Done)
        let pendingFC = VTDataManager.defaultManager.todoModelsFetchedController(ListType.Pending)
        
        do {
            try doneFC.performFetch()
            try pendingFC.performFetch()
        } catch {
            
            XCTFail("Can not fetch!")
        }
    }
    
    
    
    func testTotalModelCount() {
        let modelCount = VTDataManager.defaultManager.counttodoModels()
        let doneFC = VTDataManager.defaultManager.todoModelsFetchedController(ListType.Done)
        let pendingFC = VTDataManager.defaultManager.todoModelsFetchedController(ListType.Pending)
        
        do {
            try doneFC.performFetch()
            try pendingFC.performFetch()
            XCTAssert(doneFC.sections![0].numberOfObjects + pendingFC.sections![0].numberOfObjects == modelCount, "TotalModelCount is not true")
        } catch {
            
            XCTFail("Can not fetch!")
        }
    }
    
    func testRequestServer() {
        let e = self.expectationWithDescription("")
        CustomService.getData({ (data) in
            for item in data {
                let dict = item.dictionaryValue
                
                XCTAssertNotNil(dict["state"]?.int)
                XCTAssertNotNil(dict["name"]?.string)
                XCTAssertNotNil(dict["id"]?.int)
                
            }
            e.fulfill()
        }) { (error) in
            XCTFail(error.debugDescription)
        }
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testChangeModelState() {
        
        let e = self.expectationWithDescription("")
        
        if let model = VTDataManager.defaultManager.todoModelsCollection()?.first {
            let originState = model.state
            
            let operation = StateOperation(withID: (model.id?.integerValue)!, delegate: nil)
            operation.start()
            
            
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
                XCTAssert(originState == model.state, "Change state too early")
            }
            
            
            let delayTime1 = dispatch_time(DISPATCH_TIME_NOW, Int64(6 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime1, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
                XCTAssert(originState != model.state, "Change state too late")
                e.fulfill()
            }
            
        } else {
            e.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    
    
    
    func testCancelChangeModelState() {
        
        let e = self.expectationWithDescription("")
        
        if let model = VTDataManager.defaultManager.todoModelsCollection()?.first {
            let originState = model.state
            
            let operation = StateOperation(withID: (model.id?.integerValue)!, delegate: nil)
            operation.start()
            
            
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
                XCTAssert(originState == model.state, "Change state too early")
                
                operation.cancel()
            }
            
            
            let delayTime1 = dispatch_time(DISPATCH_TIME_NOW, Int64(6 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime1, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
                XCTAssert(originState == model.state, "Cancel state is not working")
                e.fulfill()
            }
            
        } else {
            e.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    
    
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    
}
