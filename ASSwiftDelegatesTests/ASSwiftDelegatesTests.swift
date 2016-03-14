//
//  ASSwiftDelegatesTests.swift
//  ASSwiftDelegatesTests
//
//  Copyright © 2016 AppSonic. ( http://appsonic.fr/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.



import XCTest
@testable import ASSwiftDelegates




class ASSwiftDelegatesTests: XCTestCase {
    
    class SampleManagerDelegate {
        var somethingDidChanged:(() -> Void)?
        var deinitExpectation:XCTestExpectation?
        
        init (deinitExpectation:XCTestExpectation?) {
            self.deinitExpectation = deinitExpectation
        }
        
        deinit {
            deinitExpectation?.fulfill()
        }
    }
    
    class SampleManager : ManagerWithDelegates {
        var delegateCollection = DelegateCollection<SampleManagerDelegate> ()
        
        func doBusinessThing () {
            //...
            delegateCollection.fire() {
                delegate in
                delegate.somethingDidChanged?()
            }
            //...
        }
    }
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func createDelegate (action:()->Void) -> SampleManagerDelegate {
        let deinitExpectation = self.expectationWithDescription("deinit")
        let delegate = SampleManagerDelegate(deinitExpectation: deinitExpectation)
        delegate.somethingDidChanged = {action ()}
        
        return delegate
    }
    
    
    func testManagerWithDelegates() {
        do {
            let sampleManager = SampleManager ()
            
            let fireExpectation = self.expectationWithDescription("fire")
            
            let delegate = self.createDelegate () { fireExpectation.fulfill () }
            let weakTest = {
                //create a new delegate
                let delegate2 = self.createDelegate () { XCTFail ("Must not be called") }
                
                sampleManager.addDelegate(delegate2)
            }
            
            sampleManager.addDelegate(delegate)
            weakTest ()
            sampleManager.doBusinessThing()
            sampleManager.removeDelegate(delegate)
            sampleManager.doBusinessThing()
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
}
