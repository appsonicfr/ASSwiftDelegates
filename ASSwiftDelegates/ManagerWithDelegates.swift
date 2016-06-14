//
//  ManagerWithDelegates.swift
//  ASSwiftDelegates
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

import Foundation



class DelegateWrapper<T:AnyObject> : Equatable {
    weak var delegate:T?
    
    required init (delegate:T) {
        self.delegate = delegate
    }
}

func ==<T> (wrapper1:DelegateWrapper<T>, wrapper2:DelegateWrapper<T>) -> Bool {
    return wrapper1.delegate === wrapper2.delegate
}


class DelegateCollection <DelegateType:AnyObject> {
    var weakDelegates:[DelegateWrapper<DelegateType>] = []
    
    
    func remove (delegate:DelegateType) {
        let tmpWrapper = DelegateWrapper<DelegateType>(delegate: delegate)
        guard let index = weakDelegates.indexOf (tmpWrapper) else {
            return
        }
        weakDelegates.removeAtIndex (index)
    }
    
    
    func add (delegate:DelegateType) {
        weakDelegates.append(DelegateWrapper<DelegateType>(delegate: delegate))
    }
    
    func fire (action:(DelegateType)->Void) {
        for (index, wrapper) in weakDelegates.enumerate() {
            guard let delegate = wrapper.delegate else {
                weakDelegates.removeAtIndex(index)
                continue
            }
            
            action (delegate)
        }
    }
}


protocol ManagerWithDelegates {
    associatedtype DelegateType:AnyObject
    
    var delegateCollection:DelegateCollection<DelegateType> { get }
}


extension ManagerWithDelegates {
    func addDelegate (delegate:DelegateType) {
        delegateCollection.add(delegate)
    }
    
    
    func removeDelegate (delegate:DelegateType) {
        delegateCollection.remove(delegate)
    }
}


