//
//  ErrorMessages.swift
//  CustSupportApp
//
//  Created by Namarta on 07/07/22.
//

import Foundation
enum InvalidGrant:String {
    case invalid_credentials = "invalid_credentials"
    case invalid_credentials_2_left = "invalid_credentials_2_left"
    case invalid_credentials_1_left = "invalid_credentials_1_left"
    case toomanyloginfailures = "toomanyloginfailures"
    case active_temp_password = "active_temp_password"
    case expired_temp_password = "expired_temp_password"
    case `default` = ""
}
struct LoginErrorMessages {
    static func getMessage(forKey:InvalidGrant) -> String {
        switch forKey {
        case .invalid_credentials:
            return "You have entered an incorrect Optimum ID or password."
        case .invalid_credentials_1_left:
            return "You have entered an incorrect Optimum ID or password. After 1 more attempt, the account will be locked."
        case .invalid_credentials_2_left:
            return "You have entered an incorrect Optimum ID or password. After 2 more attempts, the account will be locked."
        case .toomanyloginfailures:
            return "Your account has been locked because of too many failed sign in attempts. Please try again in 15 mins."
        default:
            return "You have entered an incorrect Optimum ID or password."
        }
    }
}

enum APIFailure:String {
    case set_networkpoint_edit_failure = "set_networkpoint_edit_failure" //CMA-572
    case set_change_device_owner_failure = "set_change_device_owner_failure" //CMA-570
    case set_node_household_and_master_edit_device_failure = "set_node_household_and_master_edit_device_failure" //CMA-1073
    case set_node_household_add_device_failure = "set_node_household_add_device_failure" //CMA-588 //CMA-643
    case set_node_edit_device_name_failure = "set_node_edit_device_name_failure" //CMA-573
    case set_pause_internet_failure = "set_pause_internet_failure" //CMA-568
    case set_profile_failure = "set_profile_api_failure" //CMA-586
    case delete_profile_failure = "delete_profile_api_failure"
    case troubleshoot_dead_zone_and_speed_test_failure = "troubleshoot_dead_zone_and_speed_test_failure" //CMA-602 // CMA-603
    case more_options_speed_test_failure = "more_options_speed_test_failure" //CMA-595
    case set_pauseinternet_for_profile_apifailure = "set_pauseinternet_for_profile_apifailure" // CMA-590
    case set_unpause_internet_failure = "set_unpause_internet_failure" // 569
    case set_unpause_internet_failureforProfile = "set_unpause_internet_failureforProfile" //CMA-591
    case wifi_home_rfOutage_failure = "wifi_home_rfOutage_failure" //CMA-389
    case billing_notification_API_failure = "billing_notification_API_failure"
    case cancel_payment_API_failure = "cancel_payment_API_failure"
    case autoPay_setup_API_failure_after_MOP = "autoPay_setup_API_failure_after_MOP" // CMAIOS-2623
}

struct GeneralAPIFailureMessages {
    static func getAPIFailureMessage(forKey:APIFailure, subTitleMessage: String = "") -> (String, String) {
        let subtitleString = "Please try again later."
        let subtitleTryAgainString = "Try again later."
        let subtitleSettingsTryAgainString = "We can’t update your \(subTitleMessage) settings. Please try again later."
        let subtitleNotifyService = "We'll notify you when service is restored."
        let subtitleCancelPayment = "We can’t cancel your \(subTitleMessage) right now. Please try again later."
        let subtitleAutoPayFailureAfterMOP = "\(subTitleMessage) has been saved, but we weren't able to update your Auto Pay settings. Please try again later."
        
        switch forKey {
        case .set_node_household_and_master_edit_device_failure:
            return ("Sorry, we ran into a problem and can’t add or remove devices right now.", subtitleString)
        case .set_node_edit_device_name_failure:
            let subtitleText = "We can’t update your device settings.\n" + subtitleString
            return ("Sorry, we ran into a problem.", subtitleText)
        case .set_pause_internet_failure:
            return ("Sorry, we ran into a problem and can’t pause your device right now.", subtitleTryAgainString)
        case .set_change_device_owner_failure:
            return ("Sorry, we ran into a problem and can’t update your device settings right now.", "")
        case .set_networkpoint_edit_failure:
            return ("Sorry, we ran into a problem.", subtitleSettingsTryAgainString)
        case .set_profile_failure:
            return ("Sorry, we ran into a problem.", subTitleMessage)
        case .troubleshoot_dead_zone_and_speed_test_failure:
            return ("Sorry, we ran into a problem and can’t complete a health check right now.", subtitleTryAgainString)
        case .more_options_speed_test_failure:
            return ("Sorry, we ran into a problem and can’t run a speed test right now.", "")
        case .set_pauseinternet_for_profile_apifailure:
            return ("Sorry, we ran into a problem and can’t pause this profile right now.", subtitleTryAgainString)
        case .set_unpause_internet_failure:
                    return ("Sorry, we ran into a problem and can’t unpause your device right now.", subtitleTryAgainString)
        case .set_unpause_internet_failureforProfile:
            return ("Sorry, we ran into a problem and can’t unpause this profile right now.", subtitleTryAgainString)
        case .wifi_home_rfOutage_failure:
            return ("Due to an outage in your area, we can't communicate with your network at this time.", subtitleNotifyService)
        case .billing_notification_API_failure : return ("Sorry, we ran into a problem.",subtitleString )//CMAIOS-2622
        case .delete_profile_failure:
            return ("Sorry, we ran into a problem and can't delete this profile right now.",subtitleTryAgainString)
        case .set_node_household_add_device_failure:
            return ("Sorry, we ran into a problem and can’t add devices right now.", subtitleString)
        case .cancel_payment_API_failure:
            return ("Sorry, we ran into a problem.", subtitleCancelPayment)
        case .autoPay_setup_API_failure_after_MOP: // CMAIOS-2623
            return ("Sorry, we ran into a problem.", subtitleAutoPayFailureAfterMOP)
        }
    }
}

//CMAIOS-2399
enum OutageDescription: String{
    case OutageMyWifi = "Due to an outage, your Internet service is not available \n at this time."
    case OutageTvHomePage = "Due to an outage, your TV service is not available at this time." //CMAIOS-2669
}
