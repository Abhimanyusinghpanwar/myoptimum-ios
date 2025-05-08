//
//  LoginUITests.swift
//  CustSupportAppUITests
//
//  Created by vengatesh.c on 09/05/24.
//

import XCTest

private var app: XCUIApplication!
final class LoginUITests: XCTestCase {
    var scrollCount = 0
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app = XCUIApplication()
        app.launch()
        
        LoginScreen(app: app)
            .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.LoginScreen.titleLabel, type: .label, waitForSec: 10.0)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    //MARK: LOGIN UI VALIDATION
    func testEmptyCredentialsErrorLabelIsShown() throws
    {
        LoginScreen(app: app)
            .tap(button: AccessibilityIdentifier.LoginScreen.signinButton)
            .signInExpectingError(error: TestFailureMessage.LoginScreen.emptyCredentialsErrorMessage)
    }
    
    func testEmptyUserIDErrorLabelIsShown() throws
    {
        LoginScreen(app: app)
            .type(password: XCTestConstants.LoginCredentials.DummyPassword)
            .tapDone()
            .tap(button: AccessibilityIdentifier.LoginScreen.signinButton)
            .signInExpectingError(error: TestFailureMessage.LoginScreen.emptyOptimumIDErrorMessage)
    }
    
    func testEmptyPasswordErrorLabelIsShown() throws
    {
        LoginScreen(app: app).type(optimumID: XCTestConstants.LoginCredentials.OptimumID)
            .tapDone()
            .tap(button: AccessibilityIdentifier.LoginScreen.signinButton)
            .signInExpectingError(error: TestFailureMessage.LoginScreen.emptyPasswordErrorMessage)
    }
    
    func testInvalidCredentialsFlow() throws
    {
        LoginScreen(app: app)
            .type(optimumID: XCTestConstants.LoginCredentials.DummyID)
            .tapDone()
            .type(password: XCTestConstants.LoginCredentials.DummyPassword)
            .tapDone()
            .tap(button: AccessibilityIdentifier.LoginScreen.signinButton)
            .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.LoginScreen.errorLabel, type: .label, waitForSec: 5.0)
    }
    
    func testLoginSuccessFlow() throws
    {
        LoginScreen(app: app)
            .type(optimumID: XCTestConstants.LoginCredentials.OptimumID)
            .tapDone()
            .type(password: XCTestConstants.LoginCredentials.Password)
            .tapDone()
            .tap(button: AccessibilityIdentifier.LoginScreen.signinButton)
            .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.HomeScreen.titleLabel, type: .label, waitForSec: 15.0)
            .tap(button: AccessibilityIdentifier.HomeScreen.myAccount)
            .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.MyAccount.signOut, type: .button, waitForSec: 5.0)
            .tap(button: AccessibilityIdentifier.MyAccount.signOut)
            .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.LoginScreen.titleLabel, type: .label, waitForSec: 5.0)
    }
    
    func loginAndGotoMyBill() {
        LoginScreen(app: app)
            .type(optimumID: "XGS6E43")
            .tapDone()
            .type(password: "MOAgk250")
            .tapDone()
            .tap(button: AccessibilityIdentifier.LoginScreen.signinButton)
            .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.HomeScreen.titleLabel, type: .label, waitForSec: 15.0)
            .tap(button: AccessibilityIdentifier.HomeScreen.myBill)
    }
    func testBPH() throws
    {
        let app = XCUIApplication()
        let textfiled = app.textFields[AccessibilityIdentifier.LoginScreen.optimumIdTextField]
        if textfiled.waitForExistence(timeout: 5.0) {
            loginAndGotoMyBill()
        } else {
            LoginScreen(app: app).waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.HomeScreen.titleLabel, type: .label, waitForSec: 15.0)
                .tap(button: AccessibilityIdentifier.HomeScreen.myAccount)
                .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.MyAccount.signOut, type: .button, waitForSec: 5.0)
                .tap(button: AccessibilityIdentifier.MyAccount.signOut)
                .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.LoginScreen.titleLabel, type: .label, waitForSec: 5.0)
            loginAndGotoMyBill()
        }
        let historyBtn = app.tables/*@START_MENU_TOKEN@*/.staticTexts["Billing & Payment History"]/*[[".cells.staticTexts[\"Billing & Payment History\"]",".staticTexts[\"Billing & Payment History\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        if historyBtn.waitForExistence(timeout: 10.0) {
            historyBtn.tap()
        } else {
            XCTAssert(false, "BPH not available")
        }
        let payMethodBtn = app.buttons.staticTexts["Use a different payment method"]
        let okayBtn = app.buttons.staticTexts["Okay"]
        let cancelBtn = app.buttons.staticTexts["Cancel"]
        
        let moreInfoBtn1 = app.tables.cells.buttons.staticTexts["More info"].firstMatch
        if moreInfoBtn1.waitForExistence(timeout: 30.0) {
            moreInfoBtn1.tap()
            if okayBtn.waitForExistence(timeout: 5.0) {
                okayBtn.tap()
            }
        }
        app.tables.element.swipeUp()
        let moreInfoBtn2 = app.tables.cells.buttons.staticTexts["More info"].firstMatch
        if moreInfoBtn2.waitForExistence(timeout: 30.0) {
            moreInfoBtn2.tap()
            if cancelBtn.waitForExistence(timeout: 1) {
                //ty[pe
            }
        }
       
        
    }
    
    func testIncorrectCard() throws
    {
        let app = XCUIApplication()
        let textfiled = app.textFields[AccessibilityIdentifier.LoginScreen.optimumIdTextField]
        if textfiled.waitForExistence(timeout: 5.0) {
            LoginScreen(app: app)
                .type(optimumID: XCTestConstants.LoginCredentials.OptimumID)
                .tapDone()
                .type(password: XCTestConstants.LoginCredentials.Password)
                .tapDone()
                .tap(button: AccessibilityIdentifier.LoginScreen.signinButton)
                .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.HomeScreen.titleLabel, type: .label, waitForSec: 15.0)
                .tap(button: AccessibilityIdentifier.HomeScreen.myBill)
        } else {
            LoginScreen(app: app).waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.HomeScreen.titleLabel, type: .label, waitForSec: 15.0)
                .tap(button: AccessibilityIdentifier.HomeScreen.myBill)
        }
        let btnMakePayment = app.buttons.staticTexts["Make a payment"]
        if btnMakePayment.waitForExistence(timeout: 30.0) {
            btnMakePayment.tap()
        }
        let doneBtn = app.toolbars.firstMatch.buttons["Done"]
        let enterTextField = app.textFields.firstMatch
        if enterTextField.waitForExistence(timeout: 3.0) {
            /** No amount Due scenario:
             */
            enterTextField.typeText("1.21")
            if doneBtn.waitForExistence(timeout: 10.0) {
                doneBtn.tap()
            }
        } else if app.staticTexts["Make a payment"].exists{
            /** Amount Due scenario:
             */
            let amountEdit = app.buttons.matching(identifier: "editAmountBtn").firstMatch
            if amountEdit.waitForExistence(timeout: 10.0) {
                amountEdit.tap()
                if enterTextField.waitForExistence(timeout: 3.0) {
                    enterTextField.typeText("1.21")
                    if doneBtn.waitForExistence(timeout: 10.0) {
                        doneBtn.tap()
                    }
                }
            }
        }
        
        let editBtn = app.buttons.matching(identifier: "editMOPBtn").firstMatch
        if editBtn.waitForExistence(timeout: 10.0) {
            editBtn.tap()
        }
        let addPaymentBtn = app.buttons["Add payment method"]
        if addPaymentBtn.waitForExistence(timeout: 10.0) {
            addPaymentBtn.tap()
        }
        let cardAddBtn = app.staticTexts["Credit or debit card"]
        if cardAddBtn.waitForExistence(timeout: 10.0) {
            cardAddBtn.tap()
        }
        
        let enterCardBtn = app.buttons.staticTexts["Enter card manually"]
        if enterCardBtn.waitForExistence(timeout: 2.0) {
            enterCardBtn.tap()
        }
        
        let txtName = app.textFields["Name on card"].firstMatch
        let txtCardNo = app.textFields["Card number"].firstMatch
        let expNo = app.textFields["Expiration (MM/YY)"].firstMatch
        let saveCardNickBtn = app.buttons.matching(identifier: "saveCardMOP").firstMatch
        let tncBtn = app.buttons.matching(identifier: "cardTnC").firstMatch
        
        if txtName.waitForExistence(timeout: 10.0) {
            txtName.tap()
            txtName.typeText("Test")
            txtCardNo.tap()
            //txtCardNo.typeText("6011574229193527") //- Discover
            txtCardNo.typeText("348570250878868") //- Amex
            expNo.tap()
            expNo.typeText("1124")
            saveCardNickBtn.tap()
            if doneBtn.exists {
                doneBtn.tap()
            }
            tncBtn.tap()
            app.buttons.matching(identifier: "payNowCardAction").firstMatch.tap()
        }
       // let cardSelectCell = app.tables.cells.staticTexts["Discover-3527"]
        let cardSelectCell = app.tables.cells.staticTexts["Amex-8868"]
        if cardSelectCell.waitForExistence(timeout: 3.0) {
            cardSelectCell.tap()
        }
        let continueBtn = app.buttons.staticTexts["Continue"]
        if continueBtn.waitForExistence(timeout: 10.0) {
            continueBtn.tap()
        }
        let payNowBtn = app.buttons.matching(identifier: "PayNowBtn").firstMatch
        if payNowBtn.waitForExistence(timeout: 10.0) {
            payNowBtn.tap()
        }
        if app.staticTexts["Sorry, this payment failed"].waitForExistence(timeout: 10.0) {
            let closeBtn = app.buttons.matching(identifier: "failureVCCloseBtn").firstMatch
            if app.staticTexts["wait text static"].waitForExistence(timeout: 5.0) {
                //to-do
            }
            if closeBtn.waitForExistence(timeout: 1.0) {
                closeBtn.tap()
            }
        }
        let historyBtn = app.tables/*@START_MENU_TOKEN@*/.staticTexts["Billing & Payment History"]/*[[".cells.staticTexts[\"Billing & Payment History\"]",".staticTexts[\"Billing & Payment History\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        if historyBtn.waitForExistence(timeout: 5.0) {
            historyBtn.tap()
        } else {
            //close and exit
        }
        let moreInfoBtn = app.tables.cells.buttons.staticTexts["More info"].firstMatch
        let bphTable = app.tables.matching(identifier: "bphTable").firstMatch
        if bphTable.waitForExistence(timeout: 30.0) {
            let cell = app.cells.staticTexts["Payment for $1.01 failed"].firstMatch
            let MAX_SCROLLS = 10
            var count = 0
            while cell.isHittable == false && count < MAX_SCROLLS {
                bphTable.swipeUp()
                count += 1
            }
            
            if cell.waitForExistence(timeout: 3.0) {
                let btn = cell.buttons.matching(identifier: "MoreInfoBPH").firstMatch
                if btn.waitForExistence(timeout: 3.0) {
                    btn.tap()
                } else {
                    moreInfoBtn.tap()
                }
            } else if moreInfoBtn.waitForExistence(timeout: 3.0) {
                    moreInfoBtn.tap()
                } else {
                    XCTAssertFalse(false)
                }
            
        } else {
            XCTAssertFalse(false)
        }
        let payMethodBtn = app.buttons.staticTexts["Use a different payment method"]
        let okayBtn = app.buttons.staticTexts["Okay"]
        let cancelBtn = app.buttons.staticTexts["Cancel"]
        let mayBeLater = app.buttons.staticTexts["Maybe later"]
        if payMethodBtn.waitForExistence(timeout: 5.0) {
            payMethodBtn.tap()
            if cancelBtn.waitForExistence(timeout: 5.0) {
                app.tables.firstMatch.swipeUp()
                cancelBtn.tap()
            }
        } else if okayBtn.waitForExistence(timeout: 5.0) {
            okayBtn.tap()
            XCTAssertFalse(false, "Incorrect card number does not come")
        }
        else if okayBtn.waitForExistence(timeout: 5.0) {
            mayBeLater.tap()
            XCTAssertFalse(false, "Incorrect card number does not come")
        }
        if btnMakePayment.waitForExistence(timeout: 30.0) {
            let closeBtn = app.buttons.matching(identifier: "CrossBtnMakePayment").firstMatch
            if closeBtn.waitForExistence(timeout: 1.0) {
                closeBtn.tap()
                logout()
            } else if getMyBillCrossBtn().waitForExistence(timeout: 2.0) {
                getMyBillCrossBtn().tap()
                logout()
            }
        }
    }
    
    func testInvalidRouting() throws
    {
        let app = XCUIApplication()
        let textfiled = app.textFields[AccessibilityIdentifier.LoginScreen.optimumIdTextField]
        if textfiled.waitForExistence(timeout: 5.0) {
            LoginScreen(app: app)
                .type(optimumID: XCTestConstants.LoginCredentials.OptimumID)
                .tapDone()
                .type(password: XCTestConstants.LoginCredentials.Password)
                .tapDone()
                .tap(button: AccessibilityIdentifier.LoginScreen.signinButton)
                .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.HomeScreen.titleLabel, type: .label, waitForSec: 15.0)
                .tap(button: AccessibilityIdentifier.HomeScreen.myBill)
        } else {
            LoginScreen(app: app).waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.HomeScreen.titleLabel, type: .label, waitForSec: 15.0)
                .tap(button: AccessibilityIdentifier.HomeScreen.myBill)
        }
        let btnMakePayment = app.buttons.staticTexts["Make a payment"]
        if btnMakePayment.waitForExistence(timeout: 30.0) {
            btnMakePayment.tap()
        }
        let doneBtn = app.toolbars.firstMatch.buttons["Done"]
        let enterTextField = app.textFields.firstMatch
        if enterTextField.waitForExistence(timeout: 3.0) {
            /** No amount Due scenario:
             */
            enterTextField.typeText("1.01")
            if doneBtn.waitForExistence(timeout: 10.0) {
                doneBtn.tap()
            }
        } else if app.staticTexts["Make a payment"].exists{
            /** Amount Due scenario:
             */
            let amountEdit = app.buttons.matching(identifier: "editAmountBtn").firstMatch
            if amountEdit.waitForExistence(timeout: 10.0) {
                amountEdit.tap()
                if enterTextField.waitForExistence(timeout: 3.0) {
                    enterTextField.typeText("1.01")
                    if doneBtn.waitForExistence(timeout: 10.0) {
                        doneBtn.tap()
                    }
                }
            }
        }
        
        let editBtn = app.buttons.matching(identifier: "editMOPBtn").firstMatch
        if editBtn.waitForExistence(timeout: 10.0) {
            editBtn.tap()
        }
        let addPaymentBtn = app.buttons["Add payment method"]
        if addPaymentBtn.waitForExistence(timeout: 10.0) {
            addPaymentBtn.tap()
        }
        let checkingAccBtn = app.staticTexts["Checking account"]
        if checkingAccBtn.waitForExistence(timeout: 10.0) {
            checkingAccBtn.tap()
        }
        
        let txtName = app.textFields["Name on checking account"].firstMatch
        let txtRoutingNo = app.textFields["Routing number"].firstMatch
        let txtAccNo = app.textFields["Account number"].firstMatch
        let saveACHNickBtn = app.buttons.matching(identifier: "saveACHNickname").firstMatch
        let tncBtn = app.buttons.matching(identifier: "tncCheckBoxACH").firstMatch
        
        if txtName.waitForExistence(timeout: 10.0) {
            txtName.tap()
            txtName.typeText("Test")
            txtRoutingNo.tap()
            txtRoutingNo.typeText("111111111")
            txtAccNo.tap()
            txtAccNo.typeText("000000000")
            saveACHNickBtn.tap()
            if doneBtn.exists {
                doneBtn.tap()
            }
            tncBtn.tap()
            app.buttons.matching(identifier: "ACHContinue").firstMatch.tap()
        }
        let payNowBtn = app.buttons.matching(identifier: "PayNowBtn").firstMatch
        if payNowBtn.waitForExistence(timeout: 10.0) {
            payNowBtn.tap()
        }
        if app.staticTexts["Sorry, this payment failed"].waitForExistence(timeout: 10.0) {
            let closeBtn = app.buttons.matching(identifier: "failureVCCloseBtn").firstMatch
            if app.staticTexts["wait text static"].waitForExistence(timeout: 5.0) {
                //to-do
            }
            if closeBtn.waitForExistence(timeout: 1.0) {
                closeBtn.tap()
            }
        }
        let historyBtn = app.tables/*@START_MENU_TOKEN@*/.staticTexts["Billing & Payment History"]/*[[".cells.staticTexts[\"Billing & Payment History\"]",".staticTexts[\"Billing & Payment History\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        if historyBtn.waitForExistence(timeout: 5.0) {
            historyBtn.tap()
        } else {
            //close and exit
        }
        let moreInfoBtn = app.tables.cells.buttons.staticTexts["More info"].firstMatch
        let bphTable = app.tables.matching(identifier: "bphTable").firstMatch
        if bphTable.waitForExistence(timeout: 30.0) {
            let cell = app.cells.staticTexts["Payment for $1.01 failed"].firstMatch
            let MAX_SCROLLS = 10
            var count = 0
            while cell.isHittable == false && count < MAX_SCROLLS {
                bphTable.swipeUp()
                count += 1
            }
            
            if cell.waitForExistence(timeout: 3.0) {
                let btn = cell.buttons.matching(identifier: "MoreInfoBPH").firstMatch
                if btn.waitForExistence(timeout: 3.0) {
                    btn.tap()
                } else {
                    moreInfoBtn.tap()
                }
            } else if moreInfoBtn.waitForExistence(timeout: 3.0) {
                    moreInfoBtn.tap()
                } else {
                    XCTAssertFalse(false)
                }
            
        } else {
            XCTAssertFalse(false)
        }
        let payMethodBtn = app.buttons.staticTexts["Use a different payment method"]
        let okayBtn = app.buttons.staticTexts["Okay"]
        let cancelBtn = app.buttons.staticTexts["Cancel"]
        if payMethodBtn.waitForExistence(timeout: 5.0) {
            payMethodBtn.tap()
            if cancelBtn.waitForExistence(timeout: 5.0) {
                app.tables.firstMatch.swipeUp()
                cancelBtn.tap()
            }
        } else if okayBtn.waitForExistence(timeout: 5.0) {
            okayBtn.tap()
        }
        if btnMakePayment.waitForExistence(timeout: 30.0) {
            let closeBtn = app.buttons.matching(identifier: "CrossBtnMakePayment").firstMatch
            if closeBtn.waitForExistence(timeout: 1.0) {
                closeBtn.tap()
                logout()
            } else if getMyBillCrossBtn().waitForExistence(timeout: 2.0) {
                getMyBillCrossBtn().tap()
                logout()
            }
        }
    }
    func logout() {
        /**Logout**/
        LoginScreen(app: app).waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.HomeScreen.titleLabel, type: .label, waitForSec: 15.0)
            .tap(button: AccessibilityIdentifier.HomeScreen.myAccount)
            .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.MyAccount.signOut, type: .button, waitForSec: 5.0)
            .tap(button: AccessibilityIdentifier.MyAccount.signOut)
            .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.LoginScreen.titleLabel, type: .label, waitForSec: 5.0)
    }
    func scrollToTheElement(cell: XCUIElement, tableElement: XCUIElement) -> Bool {
        if !cell.exists {
            scrollCount += 1
            tableElement.swipeUp()
            if scrollCount < 10 {
                _ = scrollToTheElement(cell: cell, tableElement: tableElement)
            } else {
                scrollCount = 0
                return false
            }
        } else {
            scrollCount = 0
            return true
        }
        return false
    }
    
    func testForgotIDButton()
    {
        LoginScreen(app: app)
            .tap(button: AccessibilityIdentifier.LoginScreen.forgotIDButton)
            .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.SafariWebView.reloadButton, type: .button, waitForSec: 15.0)
    }
    
    func testForgotPasswordButton()
    {
        LoginScreen(app: app)
            .tap(button: AccessibilityIdentifier.LoginScreen.forgotPasswordButton)
            .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.SafariWebView.reloadButton, type: .button, waitForSec: 15.0)
    }
    
    func testTermOfUseButton()
    {
        LoginScreen(app: app)
            .tapLink(button: AccessibilityIdentifier.LoginScreen.termsOfUseButton)
            .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.SafariWebView.reloadButton, type: .button, waitForSec: 15.0)
    }
    
    func testMobilePrivacyButton()
    {
        LoginScreen(app: app)
            .tapLink(button: AccessibilityIdentifier.LoginScreen.mobilePrivacyNoticeButton)
            .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.SafariWebView.reloadButton, type: .button, waitForSec: 15.0)
        
    }
    
    func getMyBillCrossBtn() -> XCUIElement {
        let app = XCUIApplication()
        
        let button = app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .button).element
        return button
    }
    
//    func testAppRec() {
//        LoginScreen(app: app)
//    }
    func testCreateIDButton()
    {
        LoginScreen(app: app)
            .tapLink(button: AccessibilityIdentifier.LoginScreen.createIDButton)
            .waitForExpectionToFullFill(targetElement: AccessibilityIdentifier.SafariWebView.reloadButton, type: .button, waitForSec: 15.0)
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
