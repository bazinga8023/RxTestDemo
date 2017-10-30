//
//  TouchPointProtocol.swift
//  TestDemo
//
//  Created by 张俊安 on 2017/9/10.
//  Copyright © 2017年 cppteam. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift


@objc protocol TouchPointDelegate: NSObjectProtocol {
    
    @objc optional func touch(at point: CGPoint, in view: UIView)
    
    @objc optional func touch(_: UIView, didTouchAt: CGPoint)
}

class TouchView: UIView, TouchPointDelegate {
    
    weak var touchDelegate: TouchPointDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        touchDelegate = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touchDelegate = touchDelegate {
            if touchDelegate.responds(to: #selector(TouchPointDelegate.touch(at:in:))) {
                let point = touches.first!.location(in: self)
                touchDelegate.touch!(at: point, in: self)
            }
        }
    }
    
    
}


// MARK:- Reactive

extension Reactive where Base: TouchView {
    
    var touchDelegate: DelegateProxy {
        
        return RxTouchViewDelegateProxy.proxyForObject(base)
    }
    
    var touchPoint: ControlEvent<CGPoint> {
        let source: Observable<CGPoint> = self.touchDelegate.methodInvoked(#selector(TouchPointDelegate.touch(at:in:)))
            .map({ a in
//                return a[0] as! CGPoint
                return try castOrThrow(CGPoint.self, a[0])
            })
        return ControlEvent(events: source)
    }
}


class RxTouchViewDelegateProxy: DelegateProxy, DelegateProxyType, TouchPointDelegate {
    static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
//        let touchView: TouchView = (object as? TouchView)!
//        return touchView.touchDelegate
        let touchView: TouchView = castOrFatalError(object)
        return touchView.touchDelegate
    }
    
    static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
//        let touchView: TouchView = (object as? TouchView)!
//        touchView.touchDelegate = delegate as? TouchPointDelegate
        let touchView: TouchView = castOrFatalError(object)
        touchView.touchDelegate = castOptionalOrFatalError(delegate)
    }
}




// MARK:- casts or fatal error

func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}

func rxFatalError(_ lastMessage: String) -> Never  {
    fatalError(lastMessage)
}

func castOrFatalError<T>(_ value: Any!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        rxFatalError("Failure converting from \(value) to \(T.self)")
    }
    
    return result
}


func castOptionalOrFatalError<T>(_ value: Any?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = castOrFatalError(value)
    return v
}



