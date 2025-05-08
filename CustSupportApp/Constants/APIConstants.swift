//
//  APIConstants.swift
//  CustSupportApp
//
//  Created by Namarta on 18/05/22.
//

import Foundation
// MARK: - Base URL
fileprivate let BASE_URL = App.getGatewayURLForEnv()

// MARK: - API URLS
fileprivate let LOGIN_URL_PATH_API = "oauth/token"
fileprivate let MAUI_TOKEN_URL_PATH_API = "maui/token"
fileprivate let LOGOUT_URL_PATH_API = "oauth/logout"
fileprivate let DEVICE_REGISTER_PATH_API = "api/device/device"
fileprivate let ACCOUNTS_API_URL_PATH_API = "api/account/"
fileprivate let LIGHTSPEED_API_URL_PATH_API = "api/lightspeed/livetopology/"
fileprivate let CONFIG_API_SERVICE_URL = "api/clientConfig"
fileprivate let LIGHTSPEED_GWINFO_API_URL_PATH_API = "api/lightspeed/gwaction/gwinfo/"
fileprivate let OPERATIONALSTATUS_PATH_API = "api/lightspeed/operationalstatus/"
fileprivate let GWINFO_SETLAN_API = "api/lightspeed/gwaction/setwlan/"
fileprivate let LIGHTSPEED_GETALLNODES_API = "api/lightspeed/dbutils/getallnodes"
fileprivate let LIGHTSPEED_GETPROFILE_API = "api/lightspeed/dbutils/getprofile"
fileprivate let LIGHTSPEED_GETNODE_API = "api/lightspeed/dbutils/getnode?mac="
fileprivate let LIGHTSPEED_SETPROFILE_API = "api/lightspeed/dbutils/setprofile"
fileprivate let LIGHTSPEED_SETNODE_API = "api/lightspeed/dbutils/setnode"
fileprivate let LIGHTSPEED_REBOOT_API = "api/lightspeed/gwaction/"
fileprivate let LIGHTSPEED_WPS_API = "api/lightspeed/gwaction/wpsconnect/"
fileprivate let LIGHTSPEED_SPEEDTEST_API = "api/lightspeed/speedtest"
fileprivate let LIGHTSPEED_DEADZONE_API = "api/lightspeed/homeqoe/"
fileprivate let DEVICE_ICONS = "images/deviceIcons"
fileprivate let CHECK_HOMEIP_API = "api/account/ip"
fileprivate let PAUSE_API = "api/lightspeed/dbutils/internetpause"
fileprivate let ERROR_API = "api/error"
fileprivate let SETTINGS_API = "api/settings/settings/myoptimumapp"
fileprivate let METRICS_API = "api/metric"
fileprivate let MAP_CPEINFO = "api/lightspeed/map/cpeinfo"
// MAUI API URLS
fileprivate let MAUI_ACCOUNTS_API = "api/maui/accounts"
fileprivate let MAUI_PAYMETHOD_API = "api/maui/payMethods"
fileprivate let MAUI_LISTBILLS_API = "api/maui/bills"
fileprivate let MAUI_GETBILL_API = "api/maui/bill"
fileprivate let MAUI_GETACCOUNTBILL_API = "api/maui/billAccount"
fileprivate let MAUI_GETACCOUNTACTIVITY_API = "api/maui/billAccountActivity"
fileprivate let MAUI_NEXTPAYMENTDUE_API = "api/maui/nextPaymentDueInfo"
fileprivate let MAUI_GETBIllPREFERENCES_API = "api/maui/billCommunicationPreference"
fileprivate let MAUI_UPDATEBILLPREFERENCES_API = "api/maui/billCommunicationPreference"
fileprivate let MAUI_CREATEPAYMENT_API = "api/maui/payMethods/card"
fileprivate let MAUI_SETDEFAULTPAYMETHOD_API = "api/maui/payMethods/setDefault"
fileprivate let MAUI_UPDATEPAYMETHOD_API = "api/maui/payMethods/card"
fileprivate let MAUI_GETAUTOPAY_API = "api/maui/autoPay"
fileprivate let MAUI_REMOVEAUTOPAY_API = "api/maui/autoPay/remove"
fileprivate let MAUI_GETACCOUNTRESTRICTION_API = "api/maui/accountRestriction"
fileprivate let MAUI_ALERT_OUTAGE = "api/maui/alerts"
fileprivate let MAUI_IMMEDIATEPAYMENT_API = "api/maui/payment"
fileprivate let MAUI_ONETIMEPAYMENT_API = "api/maui/paymentNewCard"
fileprivate let MAUI_LISTPAYMENT_API = "api/maui/payment"
fileprivate let MAUI_BILLPDF_API = "api/maui/billPdf"
fileprivate let MAUI_CONSOLIDATED_DETAILS_API = "api/maui/consolidatedDetails"
fileprivate let MAUI_BILLINSERTPDF_API = "api/maui/billInsertPdf"
fileprivate let MAUI_CUSTOMER_API = "api/maui/customer"
fileprivate let MAUI_CREATE_BANKACCOUNTPAYMETHOD_API = "api/maui/payMethods/ach"
fileprivate let MAUI_GETBANK_IMAGE_WITHROUTING_NUM_API = "api/maui/bank/routing"
fileprivate let MAUI_ONETIMEPAYMENT_ACH_API = "api/maui/paymentNewACH"
fileprivate let MAUI_SPOTLIGHTS_CARD_API = "api/maui/spotlightCards"
fileprivate let MAUI_DELETE_MOP_API = "api/maui/payMethods/remove" //CMAIOS-2578

// MARK: - BASE + SERVICE URLS
public let LOGIN_URL_PATH = BASE_URL + LOGIN_URL_PATH_API
public let LOGOUT_URL_PATH = BASE_URL + LOGOUT_URL_PATH_API
public let MAUI_TOKEN_URL_PATH = BASE_URL + MAUI_TOKEN_URL_PATH_API
public let REGISTER_DEVICE_URL_PATH = BASE_URL + DEVICE_REGISTER_PATH_API
public let ACCOUNTS_API_URL_PATH = BASE_URL + ACCOUNTS_API_URL_PATH_API
public let LIGHTSPEED_API_URL_PATH = BASE_URL + LIGHTSPEED_API_URL_PATH_API
public let CONFIG_API_URL = BASE_URL + CONFIG_API_SERVICE_URL
public let LIGHTSPEED_GWINFO_API_URL_PATH = BASE_URL + LIGHTSPEED_GWINFO_API_URL_PATH_API
public let OPERATIONALSTATUS_PATH_URL = BASE_URL + OPERATIONALSTATUS_PATH_API
public let SETWLAN_PATH_URL = BASE_URL + GWINFO_SETLAN_API
public let GETALLNODES_PATH_URL = BASE_URL + LIGHTSPEED_GETALLNODES_API
public let GETPROFILE_PATH_URL = BASE_URL + LIGHTSPEED_GETPROFILE_API
public let GETNODE_PATH_URL = BASE_URL + LIGHTSPEED_GETNODE_API
public let SETPROFILE_PATH_URL = BASE_URL + LIGHTSPEED_SETPROFILE_API
public let SETNODE_PATH_URL = BASE_URL + LIGHTSPEED_SETNODE_API
public let REBOOT_PATH_URL = BASE_URL + LIGHTSPEED_REBOOT_API
public let LIGHTSPEED_WPS_PATH_URL = BASE_URL + LIGHTSPEED_WPS_API
public let SPEEDTEST_PATH_URL = BASE_URL + LIGHTSPEED_SPEEDTEST_API
public let DEVICEICONS_PATH_URL = BASE_URL + DEVICE_ICONS
public let CHECK_HOMEIP_PATH_URL = BASE_URL + CHECK_HOMEIP_API
public let PAUSE_API_URL_PATH = BASE_URL + PAUSE_API
public let DEAD_ZONE_API_URL_PATH = BASE_URL + LIGHTSPEED_DEADZONE_API
public let ERROR_LOGGING_API = BASE_URL + ERROR_API
public let SETTINGS_URL_PATH = BASE_URL + SETTINGS_API
public let METRICS_URL_PATH = BASE_URL + METRICS_API
public let MAP_CPEINFO_URL_PATH = BASE_URL + MAP_CPEINFO
// MARK: - BASE + SERVICE URLS (MAUI)
public let MAUI_ACCOUNTS_PATH_URL = BASE_URL + MAUI_ACCOUNTS_API
public let MAUI_PAYMETHODS_PATH_URL = BASE_URL + MAUI_PAYMETHOD_API
public let MAUI_LISTBILLS_PATH_URL = BASE_URL + MAUI_LISTBILLS_API
public let MAUI_GETBILL_PATH_URL = BASE_URL + MAUI_GETBILL_API
public let MAUI_GETACCOUNTBILL_PATH_URL = BASE_URL + MAUI_GETACCOUNTBILL_API
public let MAUI_GETACCOUNTACTIVITY_PATH_URL = BASE_URL + MAUI_GETACCOUNTACTIVITY_API
public let MAUI_NEXTPAYMENTDUE_PATH_URL = BASE_URL + MAUI_NEXTPAYMENTDUE_API
public let MAUI_GETBIllPREFERENCES_PATH_URL = BASE_URL + MAUI_GETBIllPREFERENCES_API
public let MAUI_UPDATEBILLPREFERENCES_PATH_URL = BASE_URL + MAUI_UPDATEBILLPREFERENCES_API
public let MAUI_CREATEPAYMENT_PATH_URL = BASE_URL + MAUI_CREATEPAYMENT_API
public let MAUI_UPDATEPAYMETHOD_PATH_URL = BASE_URL + MAUI_UPDATEPAYMETHOD_API
public let MAUI_SETDEFAULTPAYMETHOD_PATH_URL = BASE_URL + MAUI_SETDEFAULTPAYMETHOD_API
public let MAUI_GETAUTOPAY_PATH_URL = BASE_URL + MAUI_GETAUTOPAY_API
public let MAUI_REMOVEAUTOPAY_PATH_URL = BASE_URL + MAUI_REMOVEAUTOPAY_API
public let MAUI_GETACCOUNTRESTRICTION_PATH_URL = BASE_URL + MAUI_GETACCOUNTRESTRICTION_API
public let MAUI_ALERT_OUTAGE_URL = BASE_URL + MAUI_ALERT_OUTAGE
public let MAUI_IMMEDIATEPAYMEN_PATH_URL = BASE_URL + MAUI_IMMEDIATEPAYMENT_API
public let MAUI_ONETIMEPAYMENT_PATH_URL = BASE_URL + MAUI_ONETIMEPAYMENT_API
public let MAUI_LISTPAYMENT_PATH_URL = BASE_URL + MAUI_LISTPAYMENT_API
public var MAUI_BILLPDF_PATH_URL = BASE_URL + MAUI_BILLPDF_API
public var MAUI_CONSOLIDATED_PATH_URL = BASE_URL + MAUI_CONSOLIDATED_DETAILS_API
public var MAUI_BILLINSERTPDF_PATH_URL = BASE_URL + MAUI_BILLINSERTPDF_API
public var MAUI_CUSTOMER_PATH_URL = BASE_URL + MAUI_CUSTOMER_API
public var MAUI_CREATE_BANKACCOUNTPAYMETHOD_URL = BASE_URL + MAUI_CREATE_BANKACCOUNTPAYMETHOD_API
public var MAUI_GETBANK_IMAGE_WITHROUTING_NUM_URL = BASE_URL + MAUI_GETBANK_IMAGE_WITHROUTING_NUM_API
public let MAUI_ACH_ONETIMEPAYMENT_PATH_URL = BASE_URL + MAUI_ONETIMEPAYMENT_ACH_API
public let MAUI_SPOTLIGHT_CARD_PATH_URL = BASE_URL + MAUI_SPOTLIGHTS_CARD_API
public let MAUI_DELETE_MOP_PATH_URL = BASE_URL + MAUI_DELETE_MOP_API //CMAIOS-2578
