//
//  ViewController.swift
//  ReactiveSwift
//
//  Created by ben on 25/05/2015.
//
//

import UIKit
import ReactiveCocoa

class ViewController: UIViewController {

    @IBOutlet weak var tfUser       :UITextField!
    @IBOutlet weak var tfPwd        :UITextField!
    @IBOutlet weak var btnLogin     :UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tfUser.text = "user"
        self.tfPwd.text = "pass"
        
        self.setupSignals()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: INIT
    
    func setupSignals() {
        
        var validUserNameSignal = self.tfUser.rac_textSignal().map(isValidUserName)
        var validPwdSignal = self.tfPwd.rac_textSignal().map(isValidPwd)
        
        RAC(self.tfUser, "backgroundColor") <~ validUserNameSignal.map(colorForValidity)
        validPwdSignal.map(colorForValidity) ~> RAC(self.tfPwd, "backgroundColor")
        
        let signupActiveSignal = RACSignal.combineLatest([validUserNameSignal, validPwdSignal]).map {
            let tuple = $0 as! RACTuple
            let bools = tuple.allObjects() as! [Bool]
            let result :Bool = bools.reduce(true) {$0 && $1}
            return result
        }
        signupActiveSignal ~> RAC(self.btnLogin, "enabled")
        
        #if EASY_WAY
            // For this simple case where we just want the logical AND of a set of NSNumber containing signals,
            // we can just use the built-in AND method on RACSignal instead of a reducer.
            RACSignal.combineLatest([validUserNameSignal, validPasswordSignal]).AND() ~> RAC(self.loginButton, "enabled")
        #endif
        
        self.btnLogin.rac_signalForControlEvents(UIControlEvents.TouchUpInside)
            .doNext { _ in
                self.btnLogin.enabled = false
            }
            .flattenMap(signInSignal)
            .subscribeNext {
                let success = $0 as! Bool
                self.btnLogin.enabled = true
//                self.signInFailureText.hidden = success
                println("Sign in result: \(success)")
                if success {
                    self.performSegueWithIdentifier("signInSuccess", sender: self)
                }
            }
    }
    
    //MARK: Private
    private func isValidUserName(name:AnyObject!) -> NSNumber! {
        return (name as! NSString).length > 3
    }
    
    private func isValidPwd(pwd:AnyObject!) -> NSNumber! {
        return (pwd as! NSString).length > 3
    }
    
    private func colorForValidity(valid : AnyObject!) -> UIColor! {
        return (valid as! Bool) ? UIColor.clearColor() : UIColor.yellowColor()
    }
    
    private func signInSignal(_ : AnyObject!) -> RACSignal {
        return RACSignal.createSignal {
            subscriber in
            self.signIn(self.tfUser.text, password: self.tfPwd.text) {
                subscriber.sendNext($0)
                subscriber.sendCompleted()
            }
            return nil
        }
    }
    
    private func signIn(username: String, password: String, complete: (Bool) -> Void) {
        let success = (username == "user" && password == "pass")
        complete(success)
    }
}

