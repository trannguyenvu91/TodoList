//
//  ArbitraryHelper.swift
//  todoGallery
//
//  Created by Vince Tran on 8/9/16.
//  Copyright © 2016 Vince Tran. All rights reserved.
//

import UIKit

class ArbitraryHelper: NSObject {

}


protocol Arbitrary {
    static func arbitrary() -> Self
}

extension Int: Arbitrary {
    static func arbitrary() -> Int {
        return Int(arc4random())
    }
    
    func smaller() -> Int? {
        return self == 0 ? nil: self / 2
    }
    
}

extension NSDate {
    static func arbitrary() -> NSDate {
        return NSDate.init(timeIntervalSince1970: Double(Int.arbitrary()))
    }
}

extension Character: Arbitrary {
    static func arbitrary() -> Character {
        return Character(UnicodeScalar(random(from: 65, to: 90)))
    }
    func smaller() -> Character? {
        return nil
    }
}

extension String: Arbitrary {
    static func arbitrary() -> String {
        let randomLength = random(from: 0, to: 50)
        let randomCharacters = tabulate(randomLength) { (_) -> Character in
            return Character.arbitrary()
        }
        return randomCharacters.reduce("", combine: { (result, c) -> String in
            return result + String(c)
        })
    }
}

func tabulate<A>(times: Int, f: Int -> A) -> [A] {
    return Array(0..<times).map(f)
}

func random(from from:Int, to:Int) -> Int {
    return from + Int(arc4random()) % (to - from)
}


