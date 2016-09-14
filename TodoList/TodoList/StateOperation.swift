//
//  ChangeStateOperation.swift
//  TodoList
//
//  Created by VuVince on 9/13/16.
//  Copyright © 2016 VuVince. All rights reserved.
//

import UIKit

@objc protocol StateOperationDelegate: NSObjectProtocol {
    func didFinishStateOperation(operation: StateOperation)
}

class StateOperation: NSOperation {
    var id:Int!
    var delegate: StateOperationDelegate?
    
    init(withID id: Int, delegate: StateOperationDelegate?) {
        super.init()
        
        self.id = id
        self.delegate = delegate
        
    }
    
    
    private var _finished : Bool = false
    
    override var finished : Bool {
        get { return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    override func main() {
        guard !self.cancelled else {
            self.finished = true
            return
        }
        
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            
            guard !self.cancelled else {
                self.finished = true
                return
            }
            
            let model = VTDataManager.defaultManager.todoModel(withID: self.id)
            model?.reverseState()
            
            if self.delegate?.respondsToSelector(#selector(StateOperationDelegate.didFinishStateOperation(_:))) != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.didFinishStateOperation(self)
                })
            }
        }
    }
}
