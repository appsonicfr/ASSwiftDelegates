# ASSwiftDelegates --}{:
This repository is a community opened solution to this question : How well implement delegates design pattern in Swift ? 


##Motivations

The delegate design pattern is in the heart of UIKit and widely use in iOs.

For more information on this design pattern, see : [Apple documentation](https://developer.apple.com/library/ios/documentation/General/Conceptual/DevPedia-CocoaCore/Delegation.html) or [Wikipedia](https://en.wikipedia.org/wiki/Delegation_pattern)

Writing a Simple delegation with only one delegate is really easy and quick in Swift :

```
protocol LoginManagerDelegate : AnyObject {
    func logStatusDidChanged ()
}

class LoginManager {
    weak var delegate:LoginManagerDelegate?
    
    func login () {
        //...
        delegate?.logStatusDidChanged()
        //...
    }
}
``` 

When times come to make an object which manage multiple delegates, things become harder and this is the aim of this piece of code : make it simplest as possible.

`NSNotificationCenter` is a great tool but cannot be use when you want to get something from your delegates. 

##Requirements

* Add more than one delegate
* Delegate must conform a given Protocol
* Don’t store strong Delegate’s references
* Limit code duplications
* Not using NSNotificationCenter


##Proposed solution

Your class only have to conform to the protocol `ManagerWithDelegates` and automatically get the following methods :

```
func addDelegate (delegate:DelegateType)
func removeDelegate (delegate:DelegateType)
func fire (action:(DelegateType)->Void) 
```

The code you need to wirte is as little as possible :

```
class LoginManagerDelegate {
    var logStatusDidChanged:(() -> Void)?
}


class LoginManager : ManagerWithDelegates {
	//You must own a DelegateCollection
    var delegateCollection = DelegateCollection<LoginManagerDelegate> ()

    func login () {
        //...
        delegateCollection.fire() {
            delegate in
            delegate.logStatusDidChanged?()
        }
        //...
    }
}
```

##What need to be improved
Access to `delegateCollection` might be limited to prevent other classes than your manager to fire its delegates.

##Communnity
Please feel free to make pull request and/or give feedback about the proposed solution.


##License
ASSwiftDelegates is released under the MIT license. See LICENSE for details.