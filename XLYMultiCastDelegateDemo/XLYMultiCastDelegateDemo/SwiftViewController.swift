//
//  SwiftViewController.swift
//  XLMultiCastDelegate
//
//  Created by kaizei on 14/9/26.
//  Copyright (c) 2014年 kaizei. All rights reserved.
//

import UIKit

// we define a swift style. in swift it is actually "moduleName.ProtocolName"
//in our demo it is "XLMultiCastDelegate.SimpleSwiftProtocol"
@objc
protocol SimpleSwiftProtocol {
    optional func someSwiftOptionalMethod()
    func someSwiftRequiredMethod(object: AnyObject!)
}

class SwiftViewController: UIViewController, SimpleProtocol, SimpleSwiftProtocol {
    //multiDelegate which uses objective-c protocol
//    var multiDelegateUsingOCProtocol = XLYMultiCastDelegate(conformingProtocol: objc_getProtocol("SimpleProtocol"))
    var multiDelegateUsingOCProtocol = XLYMultiCastDelegate(protocolName:"SimpleProtocol")
    //multiDelegate which uses swift protocol
    var multiDelegateUSingSwiftProtocol = XLYMultiCastDelegate(protocolName: "XLYMultiCastDelegateDemo.SimpleSwiftProtocol")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //here we only add one delegate 'self' to the XLMultiCastDelegate
        //😄you certainly can add more delegates in any queue😊
        multiDelegateUsingOCProtocol.addDelegate(self, dispatchQueue: dispatch_get_main_queue())
        multiDelegateUSingSwiftProtocol.addDelegate(self, dispatchQueue: dispatch_get_main_queue())
    }
    
    @IBAction func buttonClicked(button: UIButton) {
        let d1 = multiDelegateUsingOCProtocol as! SimpleProtocol
        d1.someOptionalMethod!()
        d1.someRequiredMethod(button)
        
        let d2 = multiDelegateUSingSwiftProtocol as! SimpleSwiftProtocol
        //call of someSwiftOptionalMethod will do nothing because we have no implementation
        d2.someSwiftOptionalMethod!()
        d2.someSwiftRequiredMethod(button)
    }
    
//MARK: - simple protocol
    func someRequiredMethod(object: AnyObject!) -> AnyObject! {
        println("swift viewController required method. \(object)")
        return object
    }
    
    func someOptionalMethod() {
        println("swift viewController optional method.")
    }
    
//MARK: - simple swift protocol
    func someSwiftRequiredMethod(object: AnyObject!) {
        println("swift viewController required method in SimpleSwiftProtocol.")
    }
}
