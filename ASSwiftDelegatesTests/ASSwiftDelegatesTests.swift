//
//  ASSwiftDelegatesTests.swift
//  ASSwiftDelegatesTests
//
//  Copyright © 2016 AppSonic --}{: ( http://appsonic.fr/ )
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


//Other declaration possible ...
//protocol SampleManagerDelegate {
//    var somethingDidChanged:(()->Void)? { get }
//}

@objc protocol SampleManagerDelegate {
    @objc optional func somethingDidChanged() -> Void
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


class ASSwiftDelegatesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    class MySampleManagerDelegate : SampleManagerDelegate {
        var action:(() -> Void)?
        var deinitExpectation:XCTestExpectation?
        
        init (deinitExpectation:XCTestExpectation?, action:@escaping ()->Void) {
            self.deinitExpectation = deinitExpectation
            self.action = action
        }
        
        @objc func somethingDidChanged() {
            action? ()
        }
        
        deinit {
            deinitExpectation?.fulfill()
        }
    }
    
    
    func createDelegate (_ action:@escaping ()->Void) -> SampleManagerDelegate {
        let deinitExpectation = self.expectation(description: "deinit")
        let delegate = MySampleManagerDelegate(deinitExpectation: deinitExpectation, action:action)
        
        return delegate
    }
    
    
    func testManagerWithDelegates() {
        do {
            let sampleManager = SampleManager ()
            
            let fireExpectation = self.expectation(description: "fire")
            
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
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
