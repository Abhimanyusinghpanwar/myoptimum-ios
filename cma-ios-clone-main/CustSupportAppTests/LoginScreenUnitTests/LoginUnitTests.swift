//
//  LoginUnitTests.swift
//  CustSupportAppTests
//
//  Created by vengatesh.c on 22/05/24.
//

import XCTest
@testable import CustSupportApp
final class LoginUnitTests: XCTestCase {
    
    var loginValidation: loginValidationService!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        loginValidation = loginValidationService()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        loginValidation = nil
    }
    
    func testEmptyCredentialsThrowsError() throws {
        
        XCTAssertNil(loginValidation.optimumID)
        XCTAssertNil(loginValidation.password)
        
        let expectedError = loginValidationError.emptyFields
        let validatedError = errorValidation()
        XCTAssertEqual(expectedError, validatedError)
    }
    
    func testEmptyOptimumIDThrowsError() throws
    {
        loginValidation.password = XCTestConstants.LoginCredentials.DummyPassword
        XCTAssertNil(loginValidation.optimumID)
        XCTAssertNotNil(loginValidation.password)
        
        let expectedError = loginValidationError.optimumidIsEmpty
        let validatedError = errorValidation()
        XCTAssertEqual(expectedError, validatedError)
    }
    
    func testEmptyPasswordThrowsError() throws
    {
        loginValidation.optimumID = XCTestConstants.LoginCredentials.DummyID
        XCTAssertNotNil(loginValidation.optimumID)
        XCTAssertNil(loginValidation.password)
        
        let expectedError = loginValidationError.passwordIsEmpty
        let validatedError = errorValidation()
        XCTAssertEqual(expectedError, validatedError)
    }
    
    func testInvalidCredentialsThrowsError() throws
    {
        loginValidation.optimumID = XCTestConstants.LoginCredentials.DummyID
        loginValidation.password = XCTestConstants.LoginCredentials.DummyPassword
        
        XCTAssertNotNil(loginValidation.optimumID)
        XCTAssertNotNil(loginValidation.password)
        
        let userID = XCTestConstants.LoginCredentials.DummyID
        let password = XCTestConstants.LoginCredentials.DummyPassword
        
        let testExpectation = expectation(description: "Expected login to fail with invalid credentials.")
        APIRequests.shared.initiateLoginRequest(XCTestConstants().getLoginParams(id: userID, password: password)) { success, objLoginResponse, error in
            XCTAssertFalse(success)
            testExpectation.fulfill()
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testLoginSuccess() throws
    {
        loginValidation.optimumID = XCTestConstants.LoginCredentials.OptimumID
        loginValidation.password = XCTestConstants.LoginCredentials.Password
        
        XCTAssertNotNil(loginValidation.optimumID)
        XCTAssertNotNil(loginValidation.password)
        
        let userID = XCTestConstants.LoginCredentials.OptimumID
        let password = XCTestConstants.LoginCredentials.Password
        
        let testExpectation = expectation(description: "Expected Login should be successful.")
        APIRequests.shared.initiateLoginRequest(XCTestConstants().getLoginParams(id: userID, password: password)) { success, objLoginResponse, error in
            XCTAssertTrue(success)
            testExpectation.fulfill()
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testForgotIDLink() throws
    {
        let testExpectation = expectation(description: "Expected link should be reachable.")
        loginValidation.isReachable(url: ConfigService.shared.forgotUserIdURL, completion: { success in
            XCTAssertTrue(success)
            testExpectation.fulfill()
        })
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testForgotPasswordLink() throws
    {
        let testExpectation = expectation(description: "Expected link should be reachable.")
        loginValidation.isReachable(url: ConfigService.shared.forgotPasswordURL, completion: { success in
            XCTAssertTrue(success)
            testExpectation.fulfill()
        })
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testTermOfUseLink() throws
    {
        let testExpectation = expectation(description: "Expected link should be reachable.")
        loginValidation.isReachable(url: ConfigService.shared.tosURL, completion: { success in
            XCTAssertTrue(success)
            testExpectation.fulfill()
        })
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testMobilePrivacyLink() throws
    {
        let testExpectation = expectation(description: "Expected link should be reachable.")
        loginValidation.isReachable(url: ConfigService.shared.privacyPolicyURL, completion: { success in
            XCTAssertTrue(success)
            testExpectation.fulfill()
        })
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testCreateIDLink() throws
    {
        let testExpectation = expectation(description: "Expected link should be reachable.")
        loginValidation.isReachable(url: ConfigService.shared.createUserIDURL, completion: { success in
            XCTAssertTrue(success)
            testExpectation.fulfill()
        })
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func errorValidation() -> loginValidationError
    {
        var error : loginValidationError?
        XCTAssertThrowsError(try loginValidation.validateFields())
        {
            thrownError in
            error = thrownError as? loginValidationError
        }
        return error ?? .unknownError
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

struct loginValidationService
{
    var optimumID : String?
    var password : String?
    
    func validateFields() throws -> String
    {
        guard let _ = optimumID, let _ = password else {
            if self.optimumID == nil && self.password == nil { throw loginValidationError.emptyFields }
            else if self.optimumID == nil { throw loginValidationError.optimumidIsEmpty }
            else if self.password == nil { throw loginValidationError.passwordIsEmpty }
            throw loginValidationError.unknownError
        }
        throw loginValidationError.validationSucceed
    }
    
    func isReachable(url:String, completion: @escaping (Bool) -> ()) {
        guard let url = URL(string: url) else { XCTAssertThrowsError("Failed to get URL."); return }
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { _, response, _ in
            completion((response as? HTTPURLResponse)?.statusCode == 200)
        }.resume()
    }
}

enum loginValidationError : LocalizedError
{
    case emptyFields
    case optimumidIsEmpty
    case passwordIsEmpty
    case unknownError
    case validationSucceed
    var errorDescription: String? {
        switch self
        {
        case .emptyFields:
            return "Please enter your Optimum ID and Password"
        case .optimumidIsEmpty:
            return "Please enter your Optimum ID"
        case .passwordIsEmpty:
            return "Please enter your password"
        case .unknownError:
            return "Unknown Error"
        case .validationSucceed:
            return "Validation successful"
        }
    }
}
