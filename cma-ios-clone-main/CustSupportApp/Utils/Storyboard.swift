//
//  Storyboard.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 9/8/22.
//

import UIKit

enum Storyboard: String {
    case profile
    case speedTest
    case payments
    case Troubleshooting
    case HealthCheck
    case TroubleshootInternet
    case editPayments
    case homeScreen
    case billing
    case whatsNew
    case TVTroubleshooting
    case BillPay
    case TVHomeScreen
    case Outage
    
    var instance: UIStoryboard {
        return UIStoryboard(name: rawValue.firstCapitalized, bundle: nil)
    }
    
    func instanceOf<T: UIViewController>(viewController: T.Type, identifier viewControllerIdentifier: String? = nil) -> T? {
        if let identifier = viewControllerIdentifier {
            return instance.instantiateViewController(withIdentifier: identifier) as? T
        }
        return instance.instantiateInitialViewController() as? T
    }
}

extension StringProtocol {
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
