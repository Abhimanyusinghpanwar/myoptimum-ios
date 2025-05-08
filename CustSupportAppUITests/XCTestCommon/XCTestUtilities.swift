//
//  XCTestUtilities.swift
//  CustSupportApp
//
//  Created by vengatesh.c on 13/05/24.
//

import Foundation
import XCTest

protocol Screen {
    var app: XCUIApplication { get }
}

public enum AccessibilityIdentifier {
    public enum LoginScreen {
        public static let loginScreen = "loginScreen"
        public static let titleLabel = "loginTitleLabel"
        public static let optimumIdTextField = "Optimum ID"
        public static let passwordSecureTextField = "Password"
        public static let signinButton = "Sign in"
        public static let forgotIDButton = "Forgot ID"
        public static let forgotPasswordButton = "Forgot Password"
        public static let termsOfUseButton = "Terms of Use"
        public static let mobilePrivacyNoticeButton = "Mobile Privacy Notice"
        public static let createIDButton = "Create ID"
        public static let errorLabel = "loginErrorLabel"
        public static let toolBar = "Toolbar"
        public static let done = "Done"
    }
    public enum HomeScreen {
        public static let titleLabel = "hometitleLabel"
        public static let myAccount = "My Account"
        public static let myBill = "My Bill"
    }
    public enum MyAccount {
        public static let signOut = "Sign Out"
    }
    public enum SafariWebView {
        public static let reloadButton = "ReloadButton"
    }
}

public enum TestFailureMessage {
    public enum LoginScreen {
        static let loginScreenNotDisplayed = "Login screen is not displayed."
        static let emailTextFieldNotFound = "Optimum ID field is not found."
        static let passwordTextFieldNotFound = "Password text field is not found."
        static let emptyCredentialsErrorMessage = "Please enter your Optimum ID and Password"
        static let emptyOptimumIDErrorMessage = "Please enter your Optimum ID"
        static let emptyPasswordErrorMessage = "Please enter your Password"
        static let loginNotSuccessful = "Login is not successful. Home screen is not displayed."
    }
    public enum CommonError
    {
        static let elementNotFound = "The expected element could not be located"
    }
}

public enum ElementType
{
    case textfield,label,button,view,image
}
