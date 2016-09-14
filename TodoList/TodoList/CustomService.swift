//
//  CustomService.swift
//  TodoList
//
//  Created by Vince Tran on 9/14/16.
//  Copyright © 2016 VuVince. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON



class CustomService: NSObject {
    
    static let url = "https://dl.dropboxusercontent.com/u/6890301/tasks.json"
    
    class func getData(success:([JSON]) -> Void, failure: (NSError?) -> Void) -> Request {
        return Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                
                if let result = response.result.value {
                    let json = JSON(result)
                    
                    
                    if let data = json["data"].array {
                        success(data)
                    } else {
                        failure(NSError(domain: url, code: 101, userInfo: ["object":result]))
                    }
                    
                } else {
                    let err = response.result.error
                    failure(err)
                }
        }
    }
}
