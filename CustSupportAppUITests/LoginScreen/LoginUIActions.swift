//
//  LoginUIActions.swift
//  CustSupportAppUITests
//
//  Created by vengatesh.c on 17/05/24.
//

import Foundation
import XCTest

struct LoginScreen : Screen
{
    let app: XCUIApplication
    
    func type(optimumID: String) -> Self {
        let loginTextField = app.textFields[AccessibilityIdentifier.LoginScreen.optimumIdTextField]
        loginTextField.tap()
        loginTextField.typeText(optimumID)
        return self
    }
    
    func type(password: String) -> Self {
        let passwordSecureTextField = app.secureTextFields[AccessibilityIdentifier.LoginScreen.passwordSecureTextField]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
        return self
    }
    
    @discardableResult func tapDone() -> Self
    {
        let doneButton = app.toolbars[AccessibilityIdentifier.LoginScreen.toolBar].buttons[AccessibilityIdentifier.LoginScreen.done]
        doneButton.tap()
        return self
    }
    
    @discardableResult func signInExpectingError(error messeage: String) -> Self {
        XCTAssertTrue(app.staticTexts[AccessibilityIdentifier.LoginScreen.errorLabel].exists, messeage)
        return self
    }
    
    @discardableResult func tap(button id: String) -> Self {
        let button = app.buttons[id]
        XCTAssertTrue(button.exists, "\(id) - \(TestFailureMessage.CommonError.elementNotFound)")
        button.tap()
        return self
    }
    
    @discardableResult func tapLink(button id: String) -> Self {
        let button = app.otherElements.links[id]
        XCTAssertTrue(button.exists, "\(id) - \(TestFailureMessage.CommonError.elementNotFound)")
        button.tap()
        return self
    }
    
    @discardableResult func waitForExpectionToFullFill(targetElement id:String, type element:ElementType, waitForSec timeInSeconds:Double) ->Self
    {
        if element == .label {
            XCTAssert(app.staticTexts[id].waitForExistence(timeout: timeInSeconds),"\(id) - \(TestFailureMessage.CommonError.elementNotFound)")
        }
        if element == .button
        {
            XCTAssert(app.buttons[id].waitForExistence(timeout: timeInSeconds),"\(id) - \(TestFailureMessage.CommonError.elementNotFound)")
        }
        return self
    }
}
