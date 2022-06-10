//
//  Your_Face_Tests.swift
//  Your Face Tests
//
//  Created by Tony on 11/6/2022.
//  Copyright © 2022 gotchastudio. All rights reserved.
//

import XCTest

class Your_Face_Tests: XCTestCase {
    
    let validator = Validator()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLogin() throws {
        let email = "test@test.com"
        var passowrd = ""
        
        XCTAssertFalse(validator.isAllFieldsNotEmpty(email, passowrd))
        
        passowrd = "123456"
        
        XCTAssertTrue(validator.isAllFieldsNotEmpty(email, passowrd))
    }
}
