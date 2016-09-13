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
    
    init(withID id: Int, delegate: StateOperationDelegate) {
        super.init()
        
        self.id = id
        self.delegate = delegate
        
    }
    
    override func main() {
        if self.cancelled {
            return
        }
        
        print("test start")
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            sync()
            print("test end")
            
            if self.cancelled {
                return
            }
            
            let model = VTDataManager.defaultManager.gifModel(withID: self.id)
            model?.state = model?.state == 0 ? 1 : 0
            
            if self.delegate?.respondsToSelector(#selector(StateOperationDelegate.didFinishStateOperation(_:))) != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.didFinishStateOperation(self)
                })
            }
        }
        
        
       
    }
    
    
}
