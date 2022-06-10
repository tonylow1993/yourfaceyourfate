//
//  Validator.swift
//  FaceVision
//
//  Created by Tony on 11/6/2022.
//  Copyright © 2022 gotchastudio. All rights reserved.
//

import Foundation

class Validator {
    func isPasswordValid(_ password : String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    func isAllFieldsNotEmpty(_ fields: String?...) -> Bool {
        for field in fields {
            if field == "" {
                return false
            }
        }
        return true
    }
}
