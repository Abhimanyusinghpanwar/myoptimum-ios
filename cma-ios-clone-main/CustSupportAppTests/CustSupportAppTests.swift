//
//  CustSupportAppTests.swift
//  CustSupportAppTests
//
//  Created by Jagadeesh Sriram on 4/22/22.
//

import XCTest
@testable import CustSupportApp

class CustSupportAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    func testCreditCardValidator(){
        let amexNumbers = ["378282246310005","371449635398431", "378734493671000"]
        let mastercardNumbers = ["5555555555554444", "5105105105105100"]
        let visaNumbers = ["4111111111111111", "4012888888881881", "4222222222222"]
        let discoverNumbers = ["6011111111111117", "6011000990139424"]
        let dinersClubNumbers = ["30569309025904", "38520000023237"]
        let jcbNumbers = ["3530111333300000", "3566002020360505"]
        for item in amexNumbers{
            if !CreditCardValidator.isValidNumberFor(cardType: .Amex, cardNumber: item){
                XCTAssert(false)
            }
        }
        for item in mastercardNumbers{
            if !CreditCardValidator.isValidNumberFor(cardType: .Mastercard, cardNumber: item){
                XCTAssert(false)
            }
        }
        for item in visaNumbers{
            if !CreditCardValidator.isValidNumberFor(cardType: .Visa, cardNumber: item){
                XCTAssert(false)
            }
        }
        for item in discoverNumbers{
            if !CreditCardValidator.isValidNumberFor(cardType: .Discover, cardNumber: item){
                XCTAssert(false)
            }
        }
//        for item in dinersClubNumbers{
//            if !CreditCardValidator.isValidNumberFor(cardType: .DinersClub, cardNumber: item){
//                XCTAssert(false)
//            }
//        }
//        for item in jcbNumbers{
//            if !CreditCardValidator.isValidNumberFor(cardType: .JCB, cardNumber: item){
//                XCTAssert(false)
//            }
//        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
