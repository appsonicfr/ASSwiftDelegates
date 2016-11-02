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


protocol DelegateWrapperType : Equatable {
    associatedtype DelegateType
    
    var delegate:DelegateType? { get }
}


class DelegateWrapper<T> : DelegateWrapperType {
    fileprivate weak var _delegate:AnyObject?
    
    var delegate:T? {
        get {
            if let tmp = _delegate {
                return tmp as? T
            }
            return nil
        }
    }
    
    
    required init (delegate:T) {
        _delegate = delegate as AnyObject
    }
}


func ==<T> (wrapper1:DelegateWrapper<T>, wrapper2:DelegateWrapper<T>) -> Bool {
    return wrapper1._delegate === wrapper2._delegate
}


extension Collection where Iterator.Element:DelegateWrapperType {
    func index (of element:Iterator.Element.DelegateType) ->  Self.Index? {
        let result = self.index(where: { (wrapper) -> Bool in
            if let delegate = wrapper.delegate, (delegate as AnyObject) === (element as AnyObject) {
                return true
            }
            return false
        })
        
        return result
    }
}


class DelegateCollection <DelegateType> {
    var weakDelegates:[DelegateWrapper<DelegateType>] = []
    
    
    func remove (_ delegate:DelegateType) {
        guard let index = weakDelegates.index(of: delegate) else {
            return
        }
        weakDelegates.remove (at: index)
    }
    
    
    func add (_ delegate:DelegateType) {
        guard weakDelegates.index(of: delegate) == nil else {
            return
        }
        
        let wrapper = DelegateWrapper(delegate: delegate)
        weakDelegates.append(wrapper)
    }
    
    func fire (_ action:(DelegateType)->Void) {
        for wrapper in weakDelegates {
            guard let delegate = wrapper.delegate else {
                if let index = weakDelegates.index (of: wrapper) {
                    weakDelegates.remove(at: index)
                }
                continue
            }
            
            action (delegate)
        }
    }
}


protocol ManagerWithDelegates {
    associatedtype DelegateType
    
    var delegateCollection:DelegateCollection<DelegateType> { get }
}


extension ManagerWithDelegates {
    func addDelegate (_ delegate:DelegateType) {
        delegateCollection.add(delegate)
    }
    
    func removeDelegate (_ delegate:DelegateType) {
        delegateCollection.remove(delegate)
    }
}


