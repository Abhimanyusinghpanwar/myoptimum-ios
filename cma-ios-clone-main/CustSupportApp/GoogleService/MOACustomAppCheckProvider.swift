//
//  MOACustomAppCheckProvider.swift
//  CustSupportApp
//
//  Created by Vishnu on 5/22/24.
//
import FirebaseAppCheck
import FirebaseCore

public final class MOACustomAppCheckProvider: NSObject, AppCheckProviderFactory {
    public func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        if #available(iOS 14.0, *) {
            #if DEBUG
            return AppCheckDebugProvider(app: app)
            #else
            return AppAttestProvider(app: app)
            #endif
        } else {
            return DeviceCheckProvider(app: app)
        }
    }
}
