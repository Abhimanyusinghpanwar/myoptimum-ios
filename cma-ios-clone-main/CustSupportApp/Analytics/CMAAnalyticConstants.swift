//
//  CMAAnalyticConstants.swift
//  CustSupportApp
//
//  Created by vishali Test on 21/06/23.
//

import Foundation
import FirebaseAnalytics

//FirebaeAnalytics Event Key
let EVENT_SCREEN_VIEW = AnalyticsEventScreenView

//FirebaseAnalytice Event Param Key
let EVENT_SCREEN_NAME = AnalyticsParameterScreenName
let EVENT_SCREEN_CLASS = AnalyticsParameterScreenClass
let EVENT_PARAMETER_CUSTOM_TYPE = "extender.type"
let EVENT_BUTTON_ON_CLICK = "onclick"
let EVENT_LINK_TEXT = "link_text"
//CMAIOS-2215 Added GA custom properties constants
let CUSTOM_PARAM_FIXED = "Fixed"
let CUSTOM_PARAM_INTENT = "Intent"
let CUSTOM_PARAM_CSR_TSR = "CSR_TSR"
//let CUSTOM_PARAM_CSR = "CSR"
//let CUSTOM_PARAM_TSR = "TSR"

let EVENT_PARAMETER_CUSTOM_TYPE_Extender = "extender_type"
//FirebaseAnalytics custom Event Key for Authentication
enum AuthenticationScreenDetails : String {
    case AUTHENTICATION_SIGN_IN = "authentication_sign_in"
    case AUTHENTICATION_SIGN_IN_FILLED_IN = "authentication_sign_in_filled_in"
    case AUTHENTICATION_ERROR_ENTER_ID_AND_password = "authentication_error_enter_id_and_password"
    case AUTHENTICATION_ERROR_INCORRECT_ID_OR_PASSWORD = "authentication_error_incorrect_id_or_password"
    case AUTHENTICATION_ERROR_ACCOUNT_LOCKED_AFTER_2_MORE_ATTEMPTS = "authentication_error_account_locked_after_2_more_attempts"
    case AFTER_6_ATTEMPTS = "after_6_attempts"
    case AUTHENTICATION_ERROR_NO_ID = "authentication_error_no_id"
    case AUTHENTICATION_ERROR_NO_PASSWORD = "authentication_error_no_password"
    case AUTHENTICATION_SIGN_IN_TEMPORARY_PASSWORD = "authentication_sign_in_temporary_password"
    case AUTHENTICATION_ERROR_TEMPORARY_PASSWORD_EXPIRED = "authentication_error_temporary_password_expired"
    case AUTHENTICATION_SIGN_IN_BUSINESS_ACCOUNT = "authentication_sign_in_business_account"
    case APP_UPGRADE_SCREEN = "forced_app_upgrade_screen"
    case GREETING_SCREEN = "greeting_screen"
    case SPLASH_SCREEN = "splash_screen"
    case AUTHENTICATION_READ_ONLY = "authentication_read_only"  //CMAIOS-2449
    case LOGIN_ERROR_TECHNICAL_DIFFICULTIES = "login_error_technical_difficulties" //CMAIOS-2449
}

//Event Keys for Bill Pay or Quick Pay
enum BillPayEvents: String {
    case QUICKPAY_REAUTH_SCREEN = "quickpay_re-authentication_screen"
    
    case QUICKPAY_HOME_PAGE_PAYMENT_DUE = "quickpay_home_page_payment_due"
    case QUICKPAY_NO_AUTOPAY_ENABLED = "quickpay_no_autopay_enabled"
    case QUICKPAY_NO_AUTOPAY_DEFAULT_CARD_EXPIRED = "quickpay_no_autopay_default_payment_card_expired"
    case QUICKPAY_NO_AUTOPAY_WITH_CREDIT = "quickpay_no_autopay_with_credit"
    case QUICKPAY_AUTOPAY_EXPIRED = "quickpay_autopay_expired"
    
    case QUICKPAY_CHOOSE_PAYMENT = "quickpay_choose_a_payment_method"
    case QUICKPAY_ADDCARD = "quickpay_add_credit_or_debit_card"
    
    case QUICKPAY_ADDCARD_SCAN_POP_PERMISSION = "quickpay_scan_my_card_device_pop_up_permission_to_access_camera"
    case QUICKPAY_ADDCARD_SCAN_ALLOW_ACCESS = "quickpay_scan_my_card_allow_access_card_reader"
    
    case QUICKPAY_CARDINFO_MANUAL_ADD_CARD = "quickpay_card_information_manually_add_card_information"
    case QUICKPAY_CARDINFO_MANUAL_SAVE_CARD = "quickpay_card_information_first_use_save_card"
    case QUICKPAY_CARDINFO_MANUAL_NO_SAVE_CARD = "quickpay_card_information_don't_save_card"
    case QUICKPAY_CARDINFO_MANUAL_INFO_ERROR = "quickpay_card_information_error"
    
    case QUICKPAY_CARDINFO_PAYMENT_SUCCESS = "quickpay_card_information_payment_success"
    case QUICKPAY_PAYMENT_FAILED = "quickpay_payment_failed"
    
    case QUICKPAY_PAYMENT_PAST_DUE = "quickpay_payment_past_due"
    case QUICKPAY_PAYMENT_PAST_DUE_GREATER_30_DAYS = "quickpay_payment_past_due_>30days"
    case QUICKPAY_PAYMENT_PRE_DEAUTH = "quickpay_payment_pre_deauth"
    case QUICKPAY_ONLINE_PAYMENT_BLOCKED_DE_AUTH = "quickpay_online_payment_blocked_de_auth"
    case QUICKPAY_ONLINE_PAYMENT_MANUAL_BLOCKED = "quickpay_online_payment_manual_blocked"
    
    case QUICKPAY_NO_PAYMENT_DUE = "quickpay_no_payment_due"
    case QUICKPAY_MYACCOUNT_BILLING_MENU = "myaccount_billing_menu"
    case QUICKPAY_MYACCOUNT_BILLING_MENU_AUTOPAY = "myaccount_billing_menu_autopay"
    
    case QUICKPAY_AUTOPAY_TURN_ON = "autopay_turn_on"
    case QUICKPAY_AUTOPAY_ENROLL = "autopay_enroll"
    case QUICKPAY_AUTOPAY_ENROLLMENT_CONFIRMATION = "autopay_enrollment_confirmation"
    case QUICKPAY_AUTOPAY_HOME_PAGE = "autopay_home_page"
    case QUICKPAY_AUTOPAY_CARD_EXPIRES_SOON = "autopay_card_expires_soon"
    case QUICKPAY_AUTOPAY_CARD_HAS_EXPIRED = "autopay_card_has_expired"
    
    case QUICKPAY_EDIT_AUTOPAY = "edit_autopay"
    case QUICKPAY_UPDATE_EXPIRATION = "update_expiration"
    
    case QUICKPAY_AUTOPAY_CANCEL_TURNING_ON_AUTOPAY = "autopay_cancel_turning_on_autopay"
    case QUICKPAY_AUTOPAY_TURNED_OFF = "autopay_turned_off"
    
    case QUICKPAY_PAPERLESSBILLING_ENROLL = "paperlessbilling_enroll"
    case QUICKPAY_PAPERLESSBILLING_ENROLL_SUCCESS = "paperlessbilling_enroll_success"
    case QUICKPAY_PAPERLESSBILLING_NOTIFICATION = "paperlessbilling_notification"
    
    case QUICKPAY_EDIT_PAPERLESSBILLING = "edit_paperlessbilling"
    case QUICKPAY_TURNOFF_PAPERLESSBILLING = "turnoff_paperlessbilling"
    case QUICKPAY_PAPERLESSBILLING_CANCEL = "paperlessbilling_cancel"
    case QUICKPAY_AUTOPAY_LEGACYCUSTOMER = "autopay_legacycustomer"
    
    case QUICKPAY_ERROR_PAYMENT_SYSTEM_NOT_AVAILABLE = "error_payment_system_not_available"
    case QUICKPAY_ERROR_CANCEL_ADDING_CARD = "quickpay_error_cancel_adding_card"
    
    case QUICKPAY_VIEW_MY_BILL_NEW_CUSTOMER = "quickpay_view_my_bill_new_customer"
    case QUICKPAY_VIEW_MY_BILL_NEW_LANDING = "quickpay_view_my_bill_landing"
    case AUTOPAY_LEGACY_EXCEED_MAX_LIMIT_SCREEN = "auto_pay_legacy_exceed_max_limit_screen"
    case AUTOPAY_NEEDS_ATTENTION_WITH_EAP_OPTION = "auto_pay_needs_attention_with_eap_option"
    case AUTOPAY_THANKYOU_SCREEN = "auto_pay_thank_you_screen"
    case AUTOPAY_YOU_ARE_ALL_SET = "auto_pay_you_are_all_set"
    
    case CANCEL_ADDING_CARD_SCREEN = "cancel_adding_card_screen"
    case CHOOSE_PAYMENT_FOR_AUTOPAY_SCREEN = "choose_payment_for_auto_pay_screen"
    case ERROR_ON_SAVE_MOP_SCREEN = "error_on_save_mop_screen"
    case THANKYOU_TURN_ON_AUTOPAY_SCREEN = "thank_you_turn_on_auto_pay_screen"
    case SEND_BILLING_NOTFICATION_SCREEN = "send_billing_notification_screen"
    case MY_ACCOUNT_BILLING_BILLINGMENU_PAYMENTDUE = "myaccount_billingmenu_payment_due"
    case MY_ACCOUNT_BILLING_BILLINGMENU_AUTOPAYSET = "myaccount_billingmenu_autopayset"
    case MY_ACCOUNT_BILLING_BILLINGMENU_PASTDUE = "myaccount_billingmenu_pastdue"
    case MY_ACCOUNT_BILLING_BILLINGMENU_PASTDUE_30DAYS = "myaccount_billingmenu_payment_past_due_>30days"
    case MY_ACCOUNT_BILLING_BILLINGMENU_NOPAYMENTDUE = "myaccount_billingmenu_no_payment_due"
    case MY_ACCOUNT_BILLING_BILLINGMENU_PASTDUE_PREVIOUSAMOUNT = "myaccount_billingmenu_pastdue_previousamount"
    case MY_ACCOUNT_BILLING_BILLINGMENU_PREDEAUTH = "myaccount_billingmenu_payment_pre_deauth"
    
    case VIEW_MY_BILL_BUTTON_CLICK = "view_my_bill"
    case VIEW_MY_LAST_BILL_BUTTON_CLICK = "view_my_last_bill"
    
    case AUTOPAY_PROMPT_LETS_DO_IT_CLICK = "autopay_prompt_lets_do_it"
    case AUTOPAY_PROMPT_NO_THANKS_CLICK = "autopay_prompt_no_thanks"
    case BILLING_NOT_AVAILABLE_SCREEN = "billing_not_available_right_now"
    //CMAIOS-2450
    case BNP_VIEW_BILL = "bnp_viewbill"
    case BNP_CANCEL_PAYMENT = "bnp_cancelpayment"
    case BNP_RATES_PACKAGES = "bnp_rates&packages"
}

// Partial and Schedule payments
enum PaymentScreens: String {
    case MYBILL_AMOUNT_DUE = "Mybill_amount_due"
    case MYBILL_NO_PAYMENT_DUE = "Mybill_no_payment_due"
    case MYBILL_PAST_DUE_30 = "Mybill_Past_due_+30"
    case MY_BILL_PREDEAUTH = "My Bill_Predeauth"
    case MYBILL_AUTO_PAY = "Mybill_Auto_pay"
    case MANUAL_BLOCK = "Manual_block"
    case MANUAL_BLOCK_VIEW_BILL = "Manual_block_view_bill"
    case MYBILL_MAKEAPAYMENT_PAYMENT_DUE = "Mybill_makeapayment_payment_due"
    case MYBILL_MAKEAPAYMENT_PAST_DUE_30 = "Mybill_makeapayment_past_due_+30"
    case MYBILL_MAKEAPAYMENT_SCHEDULED_PAYMENT_NOTIFICATION = "Mybill_makeapayment_scheduled_payment_notification"
    case MYBILL_MAKEAPAYMENT_NO_PAYMENT_DUE = "Mybill_makeapayment_No_payment_due"
    case MYBILL_MAKEAPAYMENT_ENTER_PAYMENT_AMOUNT_NO_PAYMENT_DUE = "Mybill_makeapayment_enter_payment_amount_no_payment_due"
    case MYBILL_MAKEAPAYMENT_ENTER_PAYMENT_AMOUNT_AMOUNT_DUE = "Mybill_makeapayment_enter_payment_amount_amount_due"
    case MYBILL_MAKEAPAYMENT_ENTERPAYMENTAMOUNT_PAST_DUE_30 = "Mybill_makeapayment_enterpaymentamount_past_due_+30"
    case MYBILL_MAKEAPAYMENT_ENTER_PAYMENT_AMOUNT_WITH_SCHEDULED_PAYMENT = "Mybill_makeapayment_enter_payment_amount_with_Scheduled_payment"
    case MYBILL_YOUR_PARTIAL_PAYMENT_SCHEDULED_BEFORE_DUE_DATE = "Mybill_your_partial_payment_scheduled_ before_due_date"
    case MYBILL_YOUR_FULL_PAYMENT_SCHEDULED = "Mybill_your_full_payment_scheduled"
    case MYBILL_YOUR_PARTIAL_PAYMENT_WITH_BALANCE = "Mybill_your_Partial_payment_with_balance"
    case MYBILL_YOUR_PARTIAL_PAYMENT_NO_BILL_DUE = "Mybill_your_Partial_payment_no_bill_due"
    case MYBILL_YOUR_PARTIAL_PAYMENT_SCHEDULED_AFTER_DUE_DATE = "Mybill_your_Partial_payment_scheduled_after_due_date"
    case MYBILL_YOUR_PARTIAL_PAYMENT_AFTER_48_HOURS_DUE_DATE = "Mybill_your_partial_payment_after_48_hours_due_date"
    case MYBILL_YOUR_PARTIAL_PAYMENT_WITHIN_48_HOURS_DUE_DATE = "Mybill_your_partial_payment_within_48_hours_due_date"
    case MYBILL_MAKEAPAYMENT_CHOOSE_PAYMENT_DATE = "Mybill_makeapayment_choose_payment_date"
    case MYBILL_MAKEAPAYMENT_CHOOSE_PAYMENT_DATE_UNKNOWN_DUE_DATE = "Mybill_makeapayment_choose_payment_date_unknown_due_date"
    case MYBILL_CHOOSE_A_PAYMENT_METHOD = "Mybill_choose_a_payment_method"
    case MYBILL_BILLING_PREFENCES_BOTH_OFF = "Mybill_Billing_prefences_both_off"
    case MYBILL_BILLING_PREFENCES_BOTH_ON = "Mybill_Billing_prefences_both_on"
    case MYBILL_BILLING_PREFENCES_AUTO_PAY_ON = "Mybill_Billing_prefences_Auto_pay_on"
    case MYBILL_BILLING_PREFENCES_PAPERLESSBILLING_ON = "Mybill_Billing_prefences_paperlessBilling_on"
    case MYBILL_BILLING_PAYMENTHISTORY_AUTO_PAY_CANCEL_REQUEST = "Mybill_Billing&paymenthistory_Auto_pay_cancel_request"
    case MYBILL_BILLING_PAYMENTHISTORY_AUTO_PAY_CANCEL_CONFIRMATION = "Mybill_Billing&paymenthistory_Auto_pay_cancel_confirmation"
    case MYBILL_BILLING_PAYMENTHISTORY_ONE_TIME_PAYMENT_CANCEL_REQUEST = "Mybill_Billing&paymenthistory_One_time_payment_cancel_request"
    case MYBILL_BILLING_PAYMENTHISTORY_ONE_TIME_PAYMENT_CANCEL_CONFIRMATION = "Mybill_Billing&paymenthistory_One_time_payment_cancel_confirmation"
    case MYBILL_BILLING_PAYMENT_HISTORY = "mybill_billing_payment_history"
    case MYBILL_BILLING_PREFERENCES = "mybill_billing_preferences"
    case MYBILL_HELP_WITH_BILLING = "mybill_help_with_billing"
    case MYBILL_MAKE_PAYMENT = "mybill_make_payment"
    case MYBILL_VIEW_MY_BILL = "mybill_view_my_bill"
    case SCHEDULED_PAYMENT_HAS_BEEN_UPDATED = "Mybill_Makeapayment_schedulepayment_yourscheduledpaymenthasbeenupdated"
    case MYBILL_MAKEPAYMENT_SCHEDULEPAYMENT_ENTER_NEW_EXPIRATION_DATE = "Mybill_Makeapayment_schedulepayment_enternewexpirationdate"
    
}
enum HomePageCards : String {
    case Home = "home"
    case Homepagecard_Deadzones = "homepagecard_deadzones"
    case Homepagecard_Network_down = "homepagecard_network_down"
    case Homepagecard_Outage = "homepagecard_outage"
    case Homepagecard_Outage_Cleared = "homepagecard_outage_cleared"
    case Homepagecard_Extender_Offline = "homepagecard_extender_offline"
    case Homepagecard_Extender_Weaksignal = "homepagecard_extender_weaksignal"
    case Homepagecard_Autopay_Scheduled = "homepagecard_autopay_scheduled"
    case Homepagecard_Billdue = "homepagecard_billdue"
    case Homepagecard_Pastdue  = "homepagecard_pastdue"
    case Homepagecard_Predeauth  = "homepagecard_predeauth"
    case Homepagecard_Autopaycard_About_to_expire  = "homepagecard_autopaycard_about_to_expire"
    case Homepagecard_Autopaycard_Expired  = "homepagecard_autopaycard_expired"
    case Homepagecard_Autopay_Amount_due_higher_than_maxamount  = "homepagecard_autopay_amount_due_higher_than_maxamount"
    case Homepagecard_ScheduledPayCard_About_to_expire  = "homepagecard_scheduledpaycard_about_to_expire"
    case Homepagecard_ScheduledPayCard_Expired  = "homepagecard_scheduledpaycard_expired"
    case Homepagecard_Thankyou   = "homepagecard_thankyou"
    case Homepagecard_Scheduledpayment_Expired = "homepagecard_scheduledpayment_expired"
    case Homepagecard_Scheduledpayment_About_To_Expire = "homepagecard_scheduledpayment_about_to_expire"
    //CMAIOS-2015
    case Homepagecard_Scheduling_Payment_Youreallset = "homepagecard_scheduling_payment_youreallset"
    //CMAIOS-2531
    case Google_Ad_Spotlight = "google_ad_spotlight"
    case Google_Ad_Spotlight_Click_to_web = "google_ad_spotlight_click_to_web"
    case Google_Ad_Spotlight_Click_to_call = "google_ad_spotlight_click_to_call"
    case Google_ad_spotlight_Event = "google_ad_spotlight_event"
    }

enum OutageSpotlightMoreInfoEvent: String { //CMAIOS-2559
    case OUTAGE_2P3P_OUTAGEDETECTED = "outage_2p3p_outagedetected"
    case OUTAGE_2P3P_INFORMFIRSTETR =  "outage_2p3p_informfirstetr"
    case OUTAGE_2P3P_TAKINGLONGERTHANEXPECTED = "outage_2p3p_takinglongerthanexpected"
    case OUTAGE_2P3P_KNOWNEWETR = "outage_2p3p_knownewetr"
    case OUTAGE_2P3P_OUTAGECLEAREDMOREINFO = "outage_2p3p_outageclearedmoreinfo"
    case OUTAGE_INTERNET_OUTAGEDETECTED = "outage_internet_outagedetected"
    case OUTAGE_INTERNET_INFORMFIRSTETR = "outage_internet_informfirstetr"
    case OUTAGE_INTERNET_TAKINGLONGERTHANEXPECTED = "outage_internet_takinglongerthanexpected"
    case OUTAGE_INTERNET_KNOWNEWETR = "outage_internet_knownewetr"
    case OUTAGE_INTERNET_OUTAGECLEAREDMOREINFO = "outage_internet_outageclearedmoreinfo"
    case OUTAGE_TV_OUTAGEDETECTED = "outage_tv_outagedetected"
    case OUTAGE_TV_INFORMFIRSTETR = "outage_tv_informfirstetr"
    case OUTAGE_TV_TAKINGLONGERTHANEXPECTED = "outage_tv_takinglongerthanexpected"
    case OUTAGE_TV_KNOWNEWETR = "outage_tv_knownewetr"
    case OUTAGE_TV_OUTAGECLEAREDMOREINFO = "outage_tv_outageclearedmoreinfo"
    case OUTAGE_PHONE_OUTAGEDETECTED = "outage_phone_outagedetected"
    case OUTAGE_PHONE_INFORMFIRSTETR = "outage_phone_informfirstetr"
    case OUTAGE_PHONE_TAKINGLONGERTHANEXPECTED = "outage_phone_takinglongerthanexpected"
    case OUTAGE_PHONE_KNOWNEWETR = "outage_phone_knownewetr"
    case OUTAGE_PHONE_OUTAGECLEAREDMOREINFO = "outage_phone_outageclearedmoreinfo"
    case MOREINFO_OUTAGE_ETR_TOMORROW = "moreinfo_outage_etr_tomorrow"
    case MOREINFO_OUTAGE2P3P_ETR_TOMORROW = "moreinfo_outage2p3p_etr_tomorrow"
}

//To make the case iterable
enum ProfileEvent : String, CaseIterable {
    case Profiles_firstuse_masterprofile_nickname = "profiles_firstuse_masterprofile_nickname"
    case Profiles_firstuse_masterprofile_avatar = "profiles_firstuse_masterprofile_avatar"
    case Profiles_firstuse_managemyhousehold = "profiles_firstuse_managemyhousehold"
    case Profiles_addperson_nickname = "profiles_addperson_nickname"
    case Profiles_addperson_avatar = "profiles_addperson_avatar"
    case Profiles_addperson_cancel = "profiles_addperson_cancel"
    case Profiles_addperson_assigndevices = "profiles_addperson_assigndevices"
    case Profiles_addperson_assigndevices_skip = "profiles_addperson_assigndevices_skip"
    case Profiles_householdprofile_setup_complete = "profiles_householdprofile_setup_complete"
    case Profiles_managemyhousehold_nohouseholdpofiles = "profiles_managemyhousehold_nohouseholdprofiles"
    case Profiles_managemyhousehold_withhouseholdprofiles = "profiles_managemyhousehold_withhouseholdprofiles"
    case Profiles_deleteprofile = "profiles_deleteprofile"
    case Profiles_view_profile_masterprofile_nodevices = "profiles_viewprofile_masterprofile_nodevices"
    case Profiles_viewproile_householdprofile_nodevices = "profiles_viewproile_householdprofile_nodevices"
    case Profiles_assigndevices_masterprofile = "profiles_assigndevices_masterprofile"
    case Profiles_assigndevices_householdprofile = "profiles_assigndevices_householdprofile"
    case Profiles_viewprofile_with_devices = "profiles_viewprofile_with_devices"
    case Profiles_edit_masterprofile_nickname = "profiles_edit_masterprofile_nickname"
    case Profiles_edit_masterprofile_avatar = "profiles_edit_masterprofile_avatar"
    case Profiles_edit_householdprofile_nickname = "profiles_edit_householdprofile_nickname"
    case Profiles_edit_householdprofile_avatar = "profiles_edit_householdprofile_avatar"
    case Profiles_edit_deviceowner = "profiles_edit_deviceowner"
}

//FirebaseAnalytics custom Event Key for MyAccountEvent
enum MyAccountScreenDetails : String {
    case MY_ACCOUNT_HOME = "myaccount_home"
    case MY_ACCOUNT_MANAGE_MY_HOUSEHOLD_PROFILES = "myaccount_manage_my_household_profiles"
    case MY_ACCOUNT_INSTALL_AN_EXTENDER = "myaccount_install_an_extender"
    case MY_ACCOUNT_BILLING = "myaccount_billing"
    case MY_ACCOUNT_ABOUT_MY_OPTIMUM = "myaccount_about_my_optimum"
}

//FirebaseAnalytics custom Event Key for Shedule Payment Failed
enum ScheduledPaymentFailureDetails  : String {
    case SCHEDULED_PAYMENT_FAILED_TECH_DIFFICULTY_AMOUNT_DUE = "scheduledpaymentfailed_techdifficulty_amountdue"
    case SCHEDULED_PAYMENT_FAILED_TECH_DIFFICULTY_NO_AMOUNT_DUE = "scheduledpaymentfailed_techdifficulty_noamountdue"
    case SCHEDULED_PAYMENT_FAILED_DUPLICATE_AMOUNT_DUE = "scheduledpaymentfailed_duplicate_amountdue"
    case SCHEDULED_PAYMENT_FAILED_DUPLICATE_NO_AMOUNT_DUE = "scheduledpaymentfailed_duplicate_noamountdue"
}

//FirebaseAnalytics custom Event Key for autoPay Failed CMAIOS-2465
enum AutoPayFailureDetails  : String {
    case AUTO_PAYMENT_FAILED_TECH_DIFFICULTY_AMOUNT_DUE = "autopaymentfailed_techdifficulty_amountdue"
    case AUTO_PAYMENT_FAILED_TECH_DIFFICULTY_NO_AMOUNT_DUE = "autopaymentfailed_techdifficulty_noamountdue"
    case THANK_YOU_AUTO_PAY_CHANGE_IT = "thankyou_autopay_changeit"
    case THANK_YOU_AUTO_PAY_NO = "thankyou_autopay_no"
    case AUTO_PAY_MOP_UPDATE_SUCCESS = "autopay_mop_update_success"
    case THANK_YOU_PAGE_CHANGE_AUTO_PAY_PROMPT  = "thankyoupage_change_autopayprompt"
}

//FirebaseAnalytics custom Event Key for WiFi Management
enum WiFiManagementScreenDetails : String {
    case WIFI_MYWIFI = "wifi_mywifi"
    case WIFI_MYNETWORK = "wifi_mynetwork"
    case WIFI_MORE_OPTIONS = "wifi_more_options"
    case WIFI_MANAGE_ROUTER_SETTINGS = "wifi_manage_router_settings"
    case WIFI_RECENTLY_DISCONNECTED_DEVICES = "wifi_recently_disconnected_devices"
    case WIFI_EDIT_DEVICE = "wifi_edit_device"
    case WIFI_DEVICE_DETAILS = "wifi_device_details"
    case WIFI_EDIT_NETWORKPOINT_NAME = "wifi_edit_networkpoint_name"
    case WIFI_NETWORKPOINT_DETAILS_GATEWAY = "wifi_networkpoint_details_gateway"
    case WIFI_NETWORKPOINT_DETAILS_EXTENDER = "wifi_networkpoint_details_extender"
    case WIFI_EDIT_NETWORK = "wifi_edit_network"
    case WIFI_EDIT_NETWORK_SUCCESS = "wifi_edit_network_success"
    case WIFI_EDIT_NETWORK_FAIL = "wifi_edit_network_fail"
    case MY_ACCOUNT_BILLING = "myaccount_billing"
    case MY_ACCOUNT_ABOUT_MY_OPTIMUM = "myaccount_about_my_optimum"
    case WIFI_HOMEPAGE_OUTAGE = "wifi_homepage_outage" //CMAIOS-2559
}

//FirebaseAnalytics custom Event Key for Troubleshooting
enum Troubleshooting : String {
    //TS_SYSRESTART
    case TS_TROUBLE_WITH_INTERNET = "ts_trouble_with_Internet"
    case TS_CHECK_OUTAGE = "ts_checkoutage"
    case TS_OUTAGE_NOT_FOUND = "ts_outage_not_found"
    case TS_OUTAGE = "ts_outage"
    case TS_SELECT_INTERNET_ISSUE = "ts_select_internet_issue"
    case TS_NO_INTERNET = "ts_no_internet"
    case TS_PROBLEM_WITH_DEVICE = "ts_problem_with_device"
    case TS_PROBLEM_WITH_DEVICE_PROBLEM_FIXED = "ts_problem_with_device_problem_fixed?"
    case TS_CONTACT_MANUFACTURER = "ts_contact_manufacturer"
    case TS_CANCEL_TROUBLESHOOTING = "ts_cancel_troubleshooting"
    case SYSTEMIC_RESTART = "systemic_restart"
    case RESTART_GATEWAY_RESTARTING = "restart_gateway_restarting"
    case RESTART_GATEWAY_BACK_ONLINE = "restart_gateway_back_online"
    case RESTART_IMPROVESPEED_GATEWAY_BACK_ONLINE = "restart_improvespeed_gateway_back_online"
    case TS_CONTACT_SUPPORT = "ts_contact_support"
    case SYSTEMIC_RESTART_GATEWAY_OFFLINE = "systemic_restart_gateway_offline"
    case TS_INTERNET_SLOW = "ts_internet_slow"
    //CMAIOS-2559
    case TS_THERES_AN_OUTAGE_IN_YOUR_AREA = "ts_theresanoutageinyourarea"
    case TS_THERES_AN_OUTAGE_IN_YOUR_AREA_IS_STILL_WANT_TO_TS = "ts_theresanoutageinyourarea_istillwanttots"
    case I_WANT_TO_TS_OUTAGE_IN_AREA = "Iwanttots_outageinarea"
    case MAY_BE_LATER_OUTAGE_IN_AREA = "maybelater_outageinarea"

    //CMAIOS-2291
    case TS_GATEWAY_INTERNET_WORKS = "ts_gateway_internet_works"
    case TS_GATEWAY_ISSUE_NOT_RESOLVED = "ts_gateway_issue_not_resolved"
    
    //
    // MANUAL RESTART GATEWAY
    case TS_MANUAL_RESTART = "ts_manual_restart"
    case TS_MANUAL_RESTART_GOTO_GATEWAY = "ts_manual_restart_goto_gateway"
    case TS_MANUAL_RESTART_UNPLUG_GATEWAY = "ts_manual_restart_unplug_gateway"
    case TS_MANUAL_RESTART_CABLE_CONNECTION = "ts_manual_restart_cable_connection"
    case TS_MANUAL_RESTART_PLUG_GATEWAY = "ts_manual_restart_plug_gateway"
    case TS_MANUAL_RESTART_GATEWAY_POWER_ON = "ts_manual_restart_gateway_power_on"
    case TS_MANUAL_RESTART_TIPS_TO_POWER_GATEWAY = "ts_manual_restart_tips_to_power_gateway"
    case TS_GATEWAY_RESTARTING_ADDITIONAL_WAIT = "ts_gateway_restarting_additional_wait"
    case TS_MANUAL_RESTART_GATEWAY_OFFLINE = "ts_manual_restart_gateway_offline"
    //
    // MANUAL RESTART ROUTER
    case TS_MANUAL_RESTART_GOTO_ROUTER = "ts_manual_restart_goto_router"
    case TS_MANUAL_RESTART_UNPLUG_ROUTER = "ts_manual_restart_unplug_router"
    case TS_MANUAL_RESTART_GOTO_MODEM = "ts_manual_restart_goto_modem"
    case TS_MANUAL_RESTART_UNPLUG_MODEM = "ts_manual_restart_unplug_modem"
    case TS_MANUAL_RESTART_PLUG_MODEM = "ts_manual_restart_plug_modem"
    case TS_MANUAL_RESTART_PLUG_ROUTER = "ts_manual_restart_plug_router"
    case TS_MANUAL_RESTART_CHECK_LIGHTS_ON_MODEM_ROUTER = "ts_manual_restart_check_lights_on_modem_router"
    case TS_MANUAL_RESTART_TIPS_TO_POWER_EQUIPMENT = "ts_manual_restart_tips_to_power_equipment"
    case TS_MANUAL_RESTART_EQUIPMENT_RESTARTING = "ts_manual_restart_equipment_restarting"
    case TS_MANUAL_RESTART_EQUIPMENT_BACKONLINE = "ts_manual_restart_equipment_backonline"
    case TS_MANUAL_RESTART_EQUIPMENT_NOT_BACKONLINE = "ts_manual_restart_equipment_not_backonline"
    //CMAIOS-2289
    case TS_EQUIPMENT_INTERNET_WORKS_NOW =  "ts_equipment_internet_works_now"
    case TS_EQUIPMENT_ISSUE_NOT_RESOLVED = "ts_equipment_issue_not_resolved"
    
    //
    // MANUAL RESTART MODEM
    case TS_MANUAL_RESTART_MODEM = "ts_manual_restart_modem"
    case TS_MANUAL_RESTART_GOTOMODEM = "ts_manual_restart_gotomodem"
    case TS_MANUAL_RESTART_UNPLUGMODEM = "ts_manual_restart_unplugmodem"
    case TS_MANUAL_RESTART_PLUGMODEM = "ts_manual_restart_plugmodem"
    case TS_MANUAL_RESTART_CHECK_LIGHTS_ON_MODEM = "ts_manual_restart_check_lights_on_modem"
    case TS_MANUAL_RESTART_TIPS_TO_POWER_MODEM = "ts_manual_restart_tips_to_power_modem"
    case TS_MANUAL_RESTART_MODEM_RESTARTING = "ts_manual_restart_modem_restarting"
    case TS_MANUAL_RESTART_MODEM_BACKONLINE = "ts_manual_restart_modem_backonline"
    case TS_MANUAL_RESTART_MODEM_NOT_BACKONLINE = "ts_manual_restart_modem_not_backonline"
    //CMAIOS-2288
    case TS_MODEM_INTERNET_WORKS_NOW = "ts_modem_internet_works_now"
    case TS_MODEM_ISSUE_NOT_RESOLVED = "ts_modem_issue_not_resolved"
    
    //
    // HEALTH CHECK
    case TS_HEALTHCHECK_START = "ts_healthcheck_start"
    case TS_HEALTHCHECK_CHECKING_NETWORK_HEALTH = "ts_healthcheck_checking_network_health"
    case TS_HEALTHCHECK_GATEWAY_OFFLINE = "ts_healthcheck_gateway_offline"
    case TS_HEALTHCHECK_EXTENDER_OFFLINE = "ts_healthcheck_extender_offline"
    case TS_HEALTHCHECK_EXTENDERS_OFFLINE = "ts_healthcheck_extenders_offline"
    case TS_HEALTHCHECK_EXTENDER_WEAKSIGNAL = "ts_healthcheck_extender_weak_signal"
    case TS_HEALTHCHECK_EXTENDERS_WEAKSIGNAL = "ts_healthcheck_extenders_weak_signal"
    case TS_HEALTHCHECK_NETWORK_EQUIPMENT_GOOD = "ts_healthcheck_network_equipment_good"
    case TS_HEALTHCHECK_CHECKING_DOWNLOAD_SPEED = "ts_healthcheck_checking_download_speed"
    case TS_HEALTHCHECK_CHECKING_SPEED = "ts_healthcheck_checking_speed"
    case TS_HEALTHCHECK_CHECKING_WIFI_DEAD_ZONES = "ts_healthcheck_checking_wifi_dead_zones"
    case TS_HEALTHCHECK_NO_WIFI_DEAD_ZONES = "ts_healthcheck_no_wifi_dead_zones"
    case TS_HEALTHCHECK_WIFI_DEAD_ZONES_DETECTED = "ts_healthcheck_wifi_dead_zones_detected"
    case TS_HEALTHCHECK_CHECKING_DEVICES = "ts_healthcheck_checking_devices"
    case TS_HEALTHCHECK_DEVICES_FINE = "ts_healthcheck_devices_fine"
    case TS_HEALTHCHECK_WIFI_GOOD = "ts_healthcheck_wifi_good"
    case TS_HEALTHCHECK_DEVICES_HAVE_WEAK_SIGNAL = "ts_healthcheck_devices_have_weak_signal"
    case TS_HEALTHCHECK_LIST_DEVICES_WITH_WEAK_SIGNAL = "ts_healthcheck_list_devices_with_weak_signal"
    //CMAIOS-2287
    case TS_INTERNET_WORKS_NOW = "ts_internet_works_now"
    case TS_INTERNET_ISSUE_NOT_RESOLVED = "ts_internet_issue_not_resolved"
    
    //CMAIOS-2290
    case TS_DEVICE_WORKS_NOW = "ts_device_works_now"
    case TS_DEVICE_ISSUE_NOT_RESOLVED = "ts_device_issue_not_resolved"
}

//FirebaseAnalytics custom Event Key for Speed Test
enum SpeedTestScreenDetails : String {
    case SPEEDTEST_CHECKING_DOWNLOAD_SPEED = "speedtest_checking_download_speed"
    case SPEEDTEST_RESULT_EXPECTED_SPEED = "speedtest_result_expected_speed"
    case SPEEDTEST_RESULT_SPEED_LESS_THAN_80_PLAN_SPEED = "speedtest_result_speed_<80%_plan_speed"
    case CHECKING_DUAL_SPEEDS  = "checking_dual_speeds"
    case SPEEDTEST_DUAL_SPEED_LESS_THAN_80_PLAN_SPEED = "speedtest_dual_speed_<80%plan_speed"
    case SPEEDTEST_DUAL_SPEED_PLAN_SPEED = "speedtest_dual_speed_plan_speed"
    case SPEEDTEST_RESET_GATEWAY_WORKED = "speedtest_reset_gateway_worked"
    case SPEED_RESET_GATEWAY_DIDNT_IMPROVE_SPEED = "speedtest_reset_gateway_didn't_improve_speed"
    case SPEEDTEST_INFLUENCING_YOUR_INTERNET_SPEED_CONFIRM = "speedtest_influencing_your_internet_speed_confirm"
    case SPEEDTEST_FACTORS_INFLUENCING_YOUR_INTERNET_SPEED = "speedtest_factors_influencing_your_internet_speed"
    case SPEEDTEST_TIPS_TO_OPTIMIZE_WIFI = "speedtest_tips_to_optimize_wifi"
    //CMAIOS-2559
    case SPEEDTEST_CHECK_FOR_OUTAGE = "speedtest_checkforoutage"
    case SPEEDTEST_CHECK_FOR_OUTAGE_NO_OUTAGE_IN_AREA = "speedtest_checkforoutage_nooutageinarea"
    case OUTAGE_IN_AREA_IS_STILL_WANT_TO_RUN_SPEED_TEST = " outageinarea_istillwanttorunaspeedtest"
    case OUTAGE_IN_AREA_MAY_BE_LATER = "outageinarea_maybelater"
    case SPEEDTEST_CHECK_FOR_OUTAGE_YES_OUTAGE_IN_AREA = "speedtest_checkforoutage_yesoutageinarea"
}
//FirebaseAnalytics custom Event Key for Error Handling Screens , CMAIOS-1384
enum ErrorScreenDetails : String {
    case ERROR_HOME_PROFILES_FAILED = "home_profiles_failed"
    case ERROR_ADD_DEVICES_FAILED = "add_devices_failed"
    case ERROR_DEVICE_DETAILS_PROFILE_ASSIGNMENT_DATA_RETRIEVAL_FAILED = "device_details_profile_assignment_data_retrieval_failed"
    case ERROR_WIFI_TECHNICAL_DIFFICULTIES = "wifi_technical_difficulties"
    case ERROR_TS_CHECK_OUTAGE_FAILED = "ts_check_outage_failed"
    case ERROR_TS_HEALTH_CHECK_FAILED = "ts_health_check_failed"
    case ERROR_SPEEDTEST_FAILED = "speedtest_failed"
    case ERROR_FIRST_USE_CREATE_MASTER_PROFILE_FAILED = "first_use_create_master_profile_failed"
    case ERROR_UPDATE_DEVICE_DETAILS_FAILED = "update_device_details_failed"
    case ERROR_WIFI_INTERIM_STATUS = "wifi_interim_status"
    case ERROR_DEVICE_ACTIVITY_API_FAILED = "device_activity_api_failed"
    case ERROR_BILLING_SELECT_AUTOPAY_FAILED = "billing_select_autopay_failed"
    case ERROR_BILLING_SELECT_PAPERLESSBILLING_FAILED = "billing_select_paperlessbilling_failed"
    case ERROR_NETWORK_POINT_SETTINGS_UPDATE_FAILED = "network_point_settings_update_failed"
    case ERROR_BILLING_AUTOPAY_ENROLLMENT_FAILED = "billing_autopay_enrollment_failed"
    case ERROR_BILLING_ADDING_MOP_FAILED = "billing_adding_mop_failed"
    case ERROR_CREATE_MASTER_PROFILE_FAILED = "create_master_profile_failed"
    case ERROR_QUICKPAY_VIEW_MY_BILL_FAILED = "quickpay_view_my_bill_failed"
    case ERROR_QUICKPAY_VIEW_MY_LAST_BILL_FAILED = "quickpay_view_my_last_bill_failed"
}

enum BillingMenuDetails : String {
    case BILLING_CANCEL_SCHEDULED_PAYMENT = "billing_cancel_scheduled_payment"
    case BILLING_VIEW_BILL_PDF = "billing_view_bill_pdf" 
    case BILLING_CANCEL_PAYMENT_CONFIRMATION = "billing_cancel_payment_confirmation"
    case BILLING_VIEW_RATES_AND_PACKAGES = "billing_view_rates&packages"
    case BILLING_AND_PAYMENT_HISTORY = "billing_and_payment_history"
    case BILLING_AND_PAYMENT_HISTORY_ONE_SCHEDULED_PAYMENT = "billing_and_payment_history_one_scheduledpayment"
    case BILLING_AND_PAYMENT_HISTORY_TWO_SCHEDULED_PAYMENT = "billing_and_payment_history_two_scheduledpayment"
}

enum WhatsNewScreenDetails : String {
    case WHATS_NEW_PAGE = "whats_new_page"
}

enum ASAPChatScreen: String {
    case Chat_Landing_Page = "chat_landing_page"
    case Chat_MyAccount = "chat_myaccount"
    case Chat_View_My_Bill_Failed = "chat_view_my_bill_failed"
    case Chat_Quickpay_Payment_Failed = "chat_quickpay_payment_failed"
    case Chat_Error_Payment_System_Not_Available = "chat_error_payment_system_not_available"
    case Chat_Quickpay_Online_Payment_Blocked_De_Auth = "chat_quickpay_online_payment_blocked_de_auth"
    case Chat_Quickpay_Online_Payment_Manual_Blocked = "chat_quickpay_online_payment_manual_blocked"
    case Chat_Billingmenu_HelpwithBilling = "chat_billingmenu_helpwithbilling"
}

enum WhatsNewBillingMenu : String {
    case HELP_WITH_BILLING = "help_with_billing"
    case HELP_WITH_BILLING_BILL_CHANGE = "help_with_billing_bill_change"
    case HELP_WITH_BILLING_LOWER_MY_BILL = "help_with_billing_lower_my_bill"
    case HELP_WITH_BILLING_PAYMENT_TROUBLE = "help_with_billing_payment_trouble"
}

//CMAIOS-2014: Manage Payment Methods
enum ManagePaymentMethod : String {
    case BILLING_MANAGE_PAYMENT_METHOD = "billing_manage_payment_method"
    case BILLING_NO_MOP_SAVED = "billing_no_mop_saved"
    case BILLING_EDIT_CARD = "billing_edit_card"
    case BILLING_EDIT_BANK = "billing_edit_bank"
    case BILLING_DELETE_MOP = "billing_delete_mop"
    case BILLING_DEFAULT_CARD_DELETION_WARNING = "billing_default_card_deletion_warning"
    case BILLING_MOP_DELETION_SCHEDULED_PAYMENT = "billing_mop_deletion_scheduled_payment"
    case DELETE_MOP_CONFIRMATION_SCREEN = "delete_mop_confirmation_screen" //CMAIOS-2819
}

//  MARK: - Extender Install
//  FirebaseAnalytics custom Event Key for Extender Install[5&6].
enum ExtenderInstallScreens {
    enum ExtenderType: String {
        case extender5_get_extender_up_and_running
        case extender5_takeout_extender
        case extender5_find_goodspot
        case extender5_halfway_one_extender
        case extender5_halfway_multiple_extenders
        case extender5_manual_placement_tipsheet1
        case extender5_manual_placement_tipsheet2
        case extender5_manual_placement_tipsheet3
        case extender5_manual_placement_goodspot
        case extender5_plug_in_extender
        case extender5_check_lights_on_extender
        case extender5_power_off_and_on
        case extender5_contact_support
        case extender5_lets_pair_extender
        case extender5_press_wps_button
        case extender5_wait_for_pairing_to_complete
        case extender5_pairing_fail_first_time
        case extender5_extender_paired
        case extender5_install_success
        case extender5_install_cancel
        
        var extenderTitle: String {
            if ExtenderDataManager.shared.extenderType == 7 {
                return self.rawValue.replacingOccurrences(of: "5", with: "6e")
            }
            return self.rawValue.replacingOccurrences(of: "5", with: "\(ExtenderDataManager.shared.extenderType ?? 5)")
        }
    }
    enum ExtenderProactivePlacementScreens: String {
        case extender6_proactive_placement_too_far
        case extender6_proactive_placement_too_close
        case extender6_proactive_placement_too_close_still_cant_find_good_spot
        case extender6_proactive_placement_return_extender
        case extender6_proactive_placement_goodspot
        case extender6_proactive_placement_connect_to_home_network
        case extender6_proactive_placement_local_network_privacy_permission
        case extender6_local_network_access_turned_off
        var extenderTitleWifi6: String {
            return self.rawValue.replacingOccurrences(of: "6", with: "6e")
        }
    }
    enum ExtenderManualPairing: String {
       case extender_manual_pairing_go_to_gateway
       case extender_manual_pairing_press_gateway_wps
       case extender_manual_pairing_press_extender_wps
       case extender_manual_pairing_first_time_failed
    }
}
//  MARK: - Extender Troubleshoot
//  FirebaseAnalytics custom Event Key for Extender Troubleshooting weak/offline[5&6].

enum ExtenderTroubleshooting {
    
    enum ExtenderOfflineTS: String {
        case extender_offline_get_extender_back_online
        case extender_offline_goto_extender
        case mutliple_extenders_offline_get_extender_back_online
        case extender_offline_return_extender
        case extender_offline_unplug_extender
        case extender_offline_plug_extender
        case extender_offline_check_extender_power
        case extender_offline_tips_to_power_extender
        case extender_offline_extender_restarting
        case extender_offline_extender_back_online
        case healthcheck_extender_offline_extender_back_online
        case extender_offline_restart_not_back_online
    }
    enum ExtenderWeakSignalTS: String {
        case extender_weaksignal_letsfix
        case extender_weaksignal_mutliple_extenders_letsfix
        case extender_weaksignal_unplug_extender
        case extender_weaksignal_move_extender_to_goodspot
        case extender_weaksignal_issue_resolved_at_newspot
        case healthcheck_extender_weaksignal_issue_resolved_at_newspot
        case extender_weaksignal_issue_notresolved_at_newspot
    }
    enum ExtenderTypeForTS: String {
        case ts_extender5_confirm_pairing_at_new_spot
        case ts_extender5_check_lights
        case ts_extender5_pair_again
        
        var extenderTitleTS: String {
            if ExtenderDataManager.shared.extenderType == 7 {
               return self.rawValue.replacingOccurrences(of: "5", with: "6e")
            }
            return self.rawValue.replacingOccurrences(of: "5", with: "\(ExtenderDataManager.shared.extenderType ?? 5)")
        }
    }
}

enum TVStreamTroubleshooting: String {
    case TV_LANDING_SCREEN = "tv_landing_screen"
    case TV_DEVICE_DETAILS = "tv_device_details"
    case TV_EDIT_DEVICE = "tv_edit_device"
    case TV_TROUBLESHOOT = "tv_troubleshoot"
    case TV_REMOTE_TROUBLESHOOT = "tv_remote_troubleshoot"
    case TV_PROGRAM_REMOTE_START = "tv_program_remote_start"
    case TV_PAIR_REMOTE_SETTINGS = "tv_pair_remote_settings"
    case TV_PAIR_REMOTE = "tv_pair_remote"
    case TV_ADD_REMOTE = "tv_add_remote"
    case TV_PROGRAM_REMOTE = "tv_program_remote"
    case TV_SEE_REMOTE = "tv_see_remote"
    case TV_REMOTE_TROUBLESHOOT_END = "tv_remote_troubleshoot_end"
    case TV_PROGRAM_REMOTE_RETRY = "tv_program_remote_retry"
    case TV_CANT_USE_VOICE = "tv_cant_use_voice"
    case TV_REMOTE_VOICE_TROUBLESHOOT_END = "tv_remote_voice_troubleshoot_end"
    case TV_MY_CHANNELS = "tv_my_channels"
    case TV_SEARCH_CHANNEL = "tv_search_channel"
    case TV_REMOTE_ADDSTREAMREMOTE = "tv_remote_addstreamremote"
    case REMOTE_WORKS_NOW_BUTTON_CLICK = "remote_works_now"
    case PAIRED_MY_REMOTE_BUTTON_CLICK = "paired_my_remote"
    case REMOTE_CONTROLS_TV_BUTTON_CLICK = "remote_controls_tv"
    case TV_HOMEPAGE_OUTAGE = "tv_homepage_outage" //CMAIOS-2559
}

enum StreamSetUp: String {
    case STREAM_SETUP_CARD = "stream_Ready_to_set_up_stream"
    case STREAM_INSTALL_SETUP = "stream_Installstart"
    case STREAM_LOOKING_FOR_STREAM = "stream_lookingforstream"
    case STREAM_FIRST_FAIL = "stream_firstfail"
    case STREAM_FOUNDSTREAM = "stream_foundstream"
    case STREAM_LETSINSTALL = "stream_letsinstallyourstream"
    case STREAM_SECONDFAIL = "stream_secondfail"
}

enum ACHPayments: String {
    case Billing_Add_Payment_Method = "billing_add_payment_method"
    case Billing_ACH_Add_Checking_Account = "billing_ach_add_checking_account"
    case Billing_ACH_Add_Checking_Autopay = "billing_ach_add_checking_autopay"
}
enum DeAuthServices: String {
    case Billing_Deauth_Services_Being_Restored = "billing_deauth_services_being_restored"
    case Billing_Deauth_Service_suspended = "billing_deauth_service_suspended"
    case Billing_Deauth_Pay_Now = "billing_deauth_pay_now"
    case Billing_Deauth_Chat = "billing_deauth_chat"
    //CMAIOS-2286
    case Billing_Deauth_Service_Suspended_Enter_Payment_Amount = "billing_deauth_service_suspended_enterpaymentamount"
    case Billing_Deauth_Service_Suspended_Make_A_Payment = "billing_deauth_service_suspended_makeapayment"
    case Billing_Deauth_Service_Suspended_Thank_You_For_Your_Payment = "billing_deauth_service_suspended_thankyouforyourpayment"
}

enum PaymentFailureScreen: String {
    case PAYMENT_FAILED_FIRST_TIME_TECH_DIFFICULTY = "paymentfailed_1sttime_techdifficulty" // CMA2295
    case PAYMENT_FAILED_SECOND_TIME_TECH_DIFFICULTY = "paymentfailed_2ndtime_techdifficulty" // CMA2297
    case PAYMENT_FAILED_EXCEEDED_LIMIT_CARD_NO_AMOUNT_DUE = "paymentfailed_exceededlimit_card_noamountdue" //2497
    case PAYMENT_FAILED_EXCEEDED_LIMIT_ACH_NO_AMOUNT_DUE = "paymentfailed_exceededlimit_ach_noamountdue" //CMA2499
    case PAYMENT_FAILED_VALIDATION_ERROR_CARD_AMOUNT_DUE = "paymentfailed_validationerror_card_amountdue" // CMA2303 // CMA2304
    case PAYMENT_FAILED_VALIDATION_ERROR_ACH_AMOUNT_DUE = "paymentfailed_validationerror_ach_amountdue" // CMA2305 // CMA2306
    case PAYMENT_FAILED_DUPLICATE_PAYMENT_PROCESSED = "paymentfailed_duplicatepayment_processed" // CMA2377
    case PAYMENT_FAILED_DUPLICATE_PAYMENT_SCHEDULED = "paymentfailed_duplicatepayment_scheduled" // CMA2378
    case PAYMENT_FAILED_EXCEEDED_LIMIT_ACH_AMOUNT_DUE = "paymentfailed_exceededlimit_ach_amountdue" // CMA2300
    case PAYMENT_FAILED_EXCEEDED_LIMIT_CARD_AMOUNT_DUE = "paymentfailed_exceededlimit_card_amountdue" // CMA2299
    // Newly added Tags
    case PAYMENT_FAILED_VALIDATION_ERROR_CARD_NO_AMOUNT_DUE = "paymentfailed_validationerror_card_noamountdue"
    case PAYMENT_FAILED_VALIDATION_ERROR_ACH_NO_AMOUNT_DUE = "paymentfailed_validationerror_ach_noamountdue"
    //
}

enum AutoPayFailureSpotlight: String {
    case PAYMENT_FAILED_AUTOPAY_CARD_EXPIRED_AMOUNT_DUE = "paymentfailed_autopay_card_expired_amountdue"
    case PAYMENT_FAILED_AUTOPAY_CARD_EXPIRED_NO_AMOUNT_DUE = "paymentfailed_autopay_card_expired_noamountdue"
    case PAYMENT_FAILED_EXCEEDED_LIMIT_CARD_MAKE_A_PAYMENT = "paymentfailed_exceededlimit_card_makeapayment"
    case PAYMENT_FAILED_EXCEEDED_LIMIT_ACH_MAKE_A_PAYMENT = "paymentfailed_exceededlimit_ach_makeapayment"
}

enum DiscountEligible: String {
    case SPOTLIGHT_CARD_INTERRUPT_ENROLL_BOTH_AP_PB = "spotlight_card_interrupt_enroll_both_ap_pb"
    case SPOTLIGHT_CARD_CHOOSE_PAYMENT_ENROLL_AP = "spotlight_card_choose_payment_enroll_ap"
    case SPOTLIGHT_CARD_BILLING_NOTIFICATIONS_ENROLL_BOTH_AP_PB = "spotlight_card_billing_notifications_enroll_both_ap_pb"
    case CONFIRMATION_ENROLLED_AP_AND_PB = "confirmation_enrolled_ap_and_pb"
    case CONFIRMATION_ENROLLED_AP_AND_PB_DONT_FORGET_TO_PAY = "confirmation_enrolled_ap_and_pb_dont_forget_to_pay"
    case CONFIRMATION_ENROLLED_AP_AND_PB_PAY_NOW = "confirmation_enrolled_ap_and_pb_pay_now"
    case ENROLLED_PAY_NOW = "enrolled_pay_now"
    case ENROLLED_ILL_DO_IT_LATER = "enrolled_ill_do_it_later"
    case ADD_PAPERLESS_BILLING_GET_DISCOUNT = "add_paperless_billing_get_discount"
    case PAPERLESS_BILLING_YOURE_ALL_SET_CONFIRMATION = "paperless_billing_youre_all_set_confirmation"
    case ADD_AUTO_PAY_GET_DISCOUNT = "add_auto_pay_get_discount"
    case ENROLL_IN_AUTO_PAY = "enroll_in_auto_pay"
    case AUTO_PAY_MAYBE_LATER = "auto_pay_maybe_later"
    case CONFIRMATION_ENROLLED_IN_AUTO_PAY = "confirmation_enrolled_in_auto_pay"
    case MY_BILL_ENROLL_IN_AUTO_PAY_AND_PAPERLESS_BILLING_INTERRUPT = "my_bill_enroll_in_auto_pay_and_paperless_billing_interrupt"
    case MORE_OPTIONS_AUTO_PAY_AND_PAPERLESS_BILLING = "more_options_auto_pay_and_paperless_billing"
    case THANK_YOUR_FOR_YOUR_PAYMENT_ENROLL_IN_AP_AND_PB_TODAY = "thank_your_for_your_payment_enroll_in_ap_and_pb_today"
    case LETS_DO_IT_ENROLL_IN_AP_PB = "lets_do_it_enroll_in_ap_pb"
    case MAYBE_LATER_ENROLL_IN_AP_PB = "maybe_later_enroll_in_ap_pb"
    case THANK_YOUR_FOR_YOUR_PAYMENT_ENROLL_IN_AP_TODAY = "thank_your_for_your_payment_enroll_in_ap_today"
    case LETS_DO_IT_ADD_AP_TO_PB = "lets_do_it_add_ap_to_pb"
    case MAYBE_LATER_ADD_AP_TO_PB = "maybe_later_add_ap_to_pb"
    case THANK_YOUR_FOR_YOUR_PAYMENT_ENROLL_IN_PB_TODAY = "thank_your_for_your_payment_enroll_in_pb_today"
    case LETS_DO_IT_ADD_PB_TO_AP = "lets_do_it_add_pb_to_ap"
    case MAYBE_LATER_ADD_PB_TO_AP = "maybe_later_add_pb_to_ap"
    case ARE_YOU_SURE_YOU_WANT_TO_TURN_OFF_AP_LOSE_DISCOUNT = "are_you_sure_you_want_to_turn_off_ap_lose_discount"
    case ARE_YOU_SURE_YOU_WANT_TO_TURN_OFF_PB_LOSE_DISCOUNT = "are_you_sure_you_want_to_turn_off_pb_lose_discount"
}

enum Fixed : String {
 case General = "General" //GENERAL
 case Data = "DATA"
 case Billing = "billing" //"BILLING"
 case Video = "Video"
}

enum CSR_TSR : String {
case CSR = "CSR"
case TSR = "TSR"
case CSR_TSR = "CSR/TSR"
}

enum Intent : String {
   case Profile = "Profile"
   case WiFi = "WIFI" // "wifi"
   case Billing = "billing" // BILLING //Billing
   case General = "general"
   case Extender = "extender" //Extender
   case Troubleshooting = "Troubleshooting" //troubleshooting
}
