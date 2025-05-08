//
//  ConfigResponseModel.swift
//  CustSupportApp
//
//  Created by Namarta on 06/06/22.
//

import Foundation
struct ConfigResponse: Decodable {
    var create_userid_url: String?
    var forgot_password_url: String?
    var forgot_userid_url: String?
    var greeting_screen_display_time_ms: String?
    var privacy_policy_url: String?
    var salutation_greetings: String?
    var tos_pp_text: String?
    var tos_url: String?
    var troubleshooting_support: String?
    var app_update_url : String?
    var asm_threshold_duration : String?
    var autopay_tos_url : String?
    var customer_support_opt_east : String?
    var customer_support_opt_west : String?
    var dns_management : String?
    var lan_setup : String?
    var omniture_report_suite_id : String?
    var outage_url : String?
    var paperless_tos_url : String?
    var port_forwarding : String?
    var port_management : String?
    var qoe_threshold : String?
    var deadspot_interval : String?
    var reset_password_url : String?
    var return_opt_east : String?
    var return_opt_west : String?
    var extender_suppress_interval : String?
    var grandfathered_text: String?
    var grandfathered_link: String?
    var grandfathered_button: String?
    var max_limit_exceeded_text: String?
    var max_limit_exceeded_button: String?
    var feedback_url: String?
    var active_temp_reset_password_url: String?
    var re_auth_duration_seconds: String?
    var whats_new: String?
    var app_rating_enabled: String?
    var app_rating_window_days: String?
    /*"ad_enabled" : true/false
    "ad_id" : "22989079085"
    "chat_support_enabled" : true/false
    "asapp_app_id": "optimumfixed"
    "asapp_host": "optimumfixed.asapp.com"*/
    var ad_enabled: String?
    var ad_id: String?
    var chat_support_enabled: String?
    var asapp_app_id: String?
    var asapp_host: String?
    var service_restoration_window: String?
    
    var dictionary: [String: Any] {
        return ["create_userid_url":create_userid_url as Any, "forgot_password_url": forgot_password_url as Any,"forgot_userid_url": forgot_userid_url as Any, "greeting_screen_display_time_ms":greeting_screen_display_time_ms as Any, "privacy_policy_url":privacy_policy_url as Any, "salutation_greetings":salutation_greetings as Any, "tos_pp_text":tos_pp_text as Any, "tos_url":tos_url as Any, "troubleshooting_support": troubleshooting_support as Any, "app_update_url":app_update_url as Any, "asm_threshold_duration": asm_threshold_duration as Any, "autopay_tos_url": autopay_tos_url as Any ,"customer_support_opt_east":customer_support_opt_east as Any, "customer_support_opt_west":customer_support_opt_west as Any, "dns_management":dns_management as Any, "lan_setup":lan_setup as Any, "omniture_report_suite_id":omniture_report_suite_id as Any, "outage_url":outage_url as Any, "paperless_tos_url":paperless_tos_url as Any,"port_forwarding":port_forwarding as Any, "port_management": port_management as Any,"qoe_threshold":qoe_threshold as Any, "reset_password_url":reset_password_url as Any,"return_opt_east":return_opt_east as Any, "return_opt_west":return_opt_west as Any,"deadspot_interval":deadspot_interval as Any, "extender_suppress_interval": extender_suppress_interval as Any, "grandfathered_text": grandfathered_text as Any, "grandfathered_link": grandfathered_link as Any, "grandfathered_button": grandfathered_button as Any, "max_limit_exceeded_text": max_limit_exceeded_text as Any, "max_limit_exceeded_button": max_limit_exceeded_button as Any, "feedback_url":feedback_url as Any, "active_temp_reset_password_url": active_temp_reset_password_url as Any, "re_auth_duration_seconds": re_auth_duration_seconds as Any, "whats_new": whats_new as Any, "app_rating_enabled": app_rating_enabled as Any, "app_rating_window_days": app_rating_window_days as Any, "ad_enabled": ad_enabled as Any, "ad_id": ad_id as Any, "chat_support_enabled": chat_support_enabled as Any, "asapp_app_id": asapp_app_id as Any, "asapp_host": asapp_host as Any, "service_restoration_window": service_restoration_window as Any]
    }

    init(create_userid_url: String, forgot_password_url: String, forgot_userid_url: String, greeting_screen_display_time_ms: String, privacy_policy_url: String, salutation_greetings: String, tos_pp_text: String, tos_url: String, troubleshooting_support: String,app_update_url: String,asm_threshold_duration: String,autopay_tos_url: String,customer_support_opt_east: String,customer_support_opt_west: String,dns_management: String,lan_setup: String,omniture_report_suite_id: String,outage_url: String,paperless_tos_url: String,port_forwarding: String,port_management: String,qoe_threshold: String,reset_password_url: String,return_opt_east: String,return_opt_west: String,deadspot_interval: String,extender_suppress_interval: String, grandfathered_text: String, grandfathered_link: String, grandfathered_button: String, max_limit_exceeded_text: String, max_limit_exceeded_button: String, feedback_url: String, active_temp_reset_password_url: String, re_auth_duration_seconds: String, whats_new: String, app_rating_enabled: String, app_rating_window_days: String, ad_enabled: String, ad_id: String, chat_support_enabled: String, asapp_app_id: String, asapp_host: String, service_restoration_window: String) {

        self.create_userid_url = create_userid_url
        self.forgot_password_url = forgot_password_url
        self.forgot_userid_url = forgot_userid_url
        self.greeting_screen_display_time_ms = greeting_screen_display_time_ms
        self.privacy_policy_url = privacy_policy_url
        self.salutation_greetings = salutation_greetings
        self.tos_pp_text = tos_pp_text
        self.tos_url = tos_url
        self.troubleshooting_support = troubleshooting_support
        self.app_update_url = app_update_url
        self.asm_threshold_duration = asm_threshold_duration
        self.autopay_tos_url = autopay_tos_url
        self.customer_support_opt_east = customer_support_opt_east
        self.customer_support_opt_west = customer_support_opt_west
        self.dns_management =  dns_management
        self.lan_setup = lan_setup
        self.omniture_report_suite_id = omniture_report_suite_id
        self.outage_url = outage_url
        self.paperless_tos_url = paperless_tos_url
        self.port_forwarding = port_forwarding
        self.port_management = port_management
        self.qoe_threshold = qoe_threshold
        self.deadspot_interval = deadspot_interval
        self.reset_password_url = reset_password_url
        self.return_opt_east = return_opt_east
        self.return_opt_west = return_opt_west
        self.extender_suppress_interval = extender_suppress_interval
        self.grandfathered_text = grandfathered_text
        self.grandfathered_link = grandfathered_link
        self.grandfathered_button = grandfathered_button
        self.max_limit_exceeded_text = max_limit_exceeded_text
        self.max_limit_exceeded_button = max_limit_exceeded_button
        self.feedback_url = feedback_url
        self.active_temp_reset_password_url = active_temp_reset_password_url
        self.re_auth_duration_seconds = re_auth_duration_seconds
        self.whats_new = whats_new
        self.app_rating_enabled = app_rating_enabled
        self.app_rating_window_days = app_rating_window_days
        self.ad_enabled = ad_enabled
        self.ad_id = ad_id
        self.chat_support_enabled = chat_support_enabled
        self.asapp_app_id = asapp_app_id
        self.asapp_host = asapp_host
        self.service_restoration_window = service_restoration_window
    }
    
   enum CodingKeys: String, CodingKey {
     case create_userid_url, forgot_password_url, forgot_userid_url, greeting_screen_display_time_ms, privacy_policy_url, salutation_greetings, tos_pp_text, tos_url, troubleshooting_support, app_update_url, asm_threshold_duration, autopay_tos_url, customer_support_opt_east, customer_support_opt_west,dns_management, lan_setup, omniture_report_suite_id, outage_url, paperless_tos_url, port_forwarding,
          port_management, qoe_threshold, reset_password_url, return_opt_east, return_opt_west, deadspot_interval, extender_suppress_interval, grandfathered_text, grandfathered_link, grandfathered_button, max_limit_exceeded_text, max_limit_exceeded_button, feedback_url, active_temp_reset_password_url, re_auth_duration_seconds, whats_new, app_rating_enabled, app_rating_window_days, ad_enabled, ad_id, chat_support_enabled, asapp_app_id, asapp_host, service_restoration_window
   }
}
class ConfigService {
    var createUserIDURL = CREATE_USERID_URL
    var forgotPasswordURL = FORGOT_PASSWORD_URL
    var forgotUserIdURL = FORGOT_USERID_URL
    var greetingScreenDisplayTime = GREETING_SCREEN_DISPLAY_TIME
    var privacyPolicyURL = PRIVACY_POLICY_URL
    var salutationGreetings = SALUTATION_GREETINGS
    var tosURL = TOS_URL
    var tosPpText  = TOS_PP_TEXT
    var troubleShootingSupport = TROUBLESHOOTING_SUPPORT
    var appUpdateUrl = APP_UPDATE_URL
    var asmThresholdDuration = ASM_THRESHOLD_DURATION
    var autopayTosURL = AUTOPAY_TOS_URL
    var customerSupportOptEast = CUSTOMER_SUPPORT_OPT_EAST
    var customerSupportOptWest = CUSTOMER_SUPPORT_OPT_WEST
    var dnsManagement = DNS_MANAGEMENT
    var lansetup = LAN_SETUP
    var omnitureReportSuitId = OMNITURE_REPORT_SUIT_ID
    var outageUrl = OUTAGE_URL
    var paperlessTosUrl = PAPERLESS_TOS_URL
    var portForwarding = PORT_FORWARDING
    var portManagement = PORT_MANAGEMENT
    var qoeThreshold = QOE_THRESHOLD
    var deadSpotInterval = DEADSPOT_INTERVAL
    var resetPasswordUrl = RESET_PASSWORD_URL
    var returnOptEast = RETURN_OPT_EAST
    var returnOptWest =  RETURN_OPT_WEST
    var extenderSuppressInterval = EXTENDER_SUPPRESS_INTERVAL
    var grandFatheredText = GRANDFATHERED_TEXT
    var grandFatheredLink = GRANDFATHERED_LINK
    var grandFatheredButton = GRANDFATHERED_BUTTON
    var maxLimitExceedButton = MAX_LIMIT_EXCEED_BUTTON
    var maxLimitExceedText = MAX_LIMIT_EXCEED_TEXT
    var feedbackURL = FEEDBACK_URL
    var activeTempResetPassUrl = ACTIVE_TEMP_RESET_PASSWORD_URL
    var reAuthDurationSeconds = RE_AUTH_DURATION_SECONDS
    var whats_new = ""
    var app_rating_enabled = APP_RATING_ENABLED
    var app_rating_window_days = APP_RATING_WINDOW_DAYS
    var ad_enabled = ""
    var ad_id = GoogleAdaptiveBannerID // Backup value
    var chat_support_enabled = ""
    var asapp_app_id = ""
    var asapp_host = ""
    var service_restoration_window = SERVICE_RESTORATION_WINDOW
    class var shared: ConfigService {
        
        struct Singleton {
            static let instance = ConfigService()
        }
        return Singleton.instance
    }
    
    func saveConfigValues(configResponse: ConfigResponse?) {
        guard let values = configResponse else {
            saveBackupValuesForConfig()
            return
        }
        
        // Create UserID URL
        if let url = values.create_userid_url, !url.isEmpty {
            self.createUserIDURL = url
        } else {
            self.createUserIDURL = CREATE_USERID_URL
        }
        
        // Forgot Password URL
        if let url = values.forgot_password_url, !url.isEmpty {
            self.forgotPasswordURL = url
        } else {
            self.forgotPasswordURL = FORGOT_PASSWORD_URL
        }
        
        // Forgot User ID URL
        if let url = values.forgot_userid_url, !url.isEmpty {
            self.forgotUserIdURL = url
        } else {
            self.forgotUserIdURL = FORGOT_USERID_URL
        }
        
        // Terms & Conditions URL
        if let url = values.tos_url, !url.isEmpty {
            self.tosURL = url
        } else {
            self.tosURL = TOS_URL
        }
        
        // Privacy Policy URL
        if let url = values.privacy_policy_url, !url.isEmpty {
            self.privacyPolicyURL = url
        } else {
            self.privacyPolicyURL = PRIVACY_POLICY_URL
        }
        
        // Greetings Screen Display Time
        if let displayTime = values.greeting_screen_display_time_ms, !displayTime.isEmpty {
            self.greetingScreenDisplayTime = displayTime
        } else {
            self.greetingScreenDisplayTime = GREETING_SCREEN_DISPLAY_TIME
        }
        
        // Salutation Greetings
        if let greetings = values.salutation_greetings, !greetings.isEmpty {
            self.salutationGreetings = greetings
        } else {
            self.salutationGreetings = SALUTATION_GREETINGS
        }
        
        if let support = values.troubleshooting_support, !support.isEmpty {
            self.troubleShootingSupport = support
        } else {
            self.troubleShootingSupport = TROUBLESHOOTING_SUPPORT
        }
        
        if let tossPPText = values.tos_pp_text, !tossPPText.isEmpty
        {
            self.tosPpText = tossPPText
        }else{
            self.tosPpText = TOS_PP_TEXT
        }
        
        if let appUpdateUrl = values.app_update_url, !appUpdateUrl.isEmpty
        {
            self.appUpdateUrl = appUpdateUrl
        }else{
            self.appUpdateUrl = APP_UPDATE_URL
        }
        
        if let asmThresholdDuration = values.asm_threshold_duration, !asmThresholdDuration.isEmpty
        {
            self.asmThresholdDuration = asmThresholdDuration
        }else{
            self.asmThresholdDuration = ASM_THRESHOLD_DURATION
        }
        
        if let autoPaytosUrl = values.autopay_tos_url , !autoPaytosUrl.isEmpty
        {
            self.autopayTosURL = autoPaytosUrl
        }else{
            self.autopayTosURL = AUTOPAY_TOS_URL
        }
        
        if let customerSupportOptEast = values.customer_support_opt_east, !customerSupportOptEast.isEmpty
        {
            self.customerSupportOptEast = customerSupportOptEast
        }else{
            self.customerSupportOptEast = CUSTOMER_SUPPORT_OPT_EAST
        }
        
        if let customerSupportOptWest = values.customer_support_opt_west , !customerSupportOptWest.isEmpty
        {
            self.customerSupportOptWest = customerSupportOptWest
        }else{
            self.customerSupportOptWest = CUSTOMER_SUPPORT_OPT_WEST
        }
    
        if let dnsManagement = values.dns_management, !dnsManagement.isEmpty
        {
            self.dnsManagement = dnsManagement
        }else{
            self.dnsManagement = DNS_MANAGEMENT
        }
        
        if let lanSetUp = values.lan_setup , !lanSetUp.isEmpty
        {
            self.lansetup = lanSetUp
        }else{
            self.lansetup = LAN_SETUP
        }
        
        if let omnitureReportSuitId = values.omniture_report_suite_id , !omnitureReportSuitId.isEmpty
        {
            self.omnitureReportSuitId = omnitureReportSuitId
        }else{
            self.omnitureReportSuitId = OMNITURE_REPORT_SUIT_ID
        }
        
        if let outageUrl = values.outage_url , !outageUrl.isEmpty
        {
            self.outageUrl = outageUrl
        }else{
            self.outageUrl = OUTAGE_URL
        }
        
        if let paperlessTosUrl = values.paperless_tos_url , !paperlessTosUrl.isEmpty
        {
            self.paperlessTosUrl = paperlessTosUrl
        }else{
            self.paperlessTosUrl = PAPERLESS_TOS_URL
        }
        
    
        if let portForwarding = values.port_forwarding, !portForwarding.isEmpty
        {
            self.portForwarding = portForwarding
        }else {
            self.portForwarding = PORT_FORWARDING
        }
        
        if let portManagement = values.port_management , !portManagement.isEmpty
        {
            self.portManagement = portManagement
        }else{
            self.portManagement = PORT_MANAGEMENT
        }
        
        if let qoeThreshold = values.qoe_threshold, !qoeThreshold.isEmpty
        {
            self.qoeThreshold = qoeThreshold
        }else{
            self.qoeThreshold = QOE_THRESHOLD
        }
        
        if let deadspotInterval = values.deadspot_interval, !deadspotInterval.isEmpty
        {
            self.deadSpotInterval = deadspotInterval
        }else{
            self.deadSpotInterval = DEADSPOT_INTERVAL
        }
        
        if let resetPasswordUrl = values.reset_password_url, !resetPasswordUrl.isEmpty
        {
            self.resetPasswordUrl = resetPasswordUrl
        }else{
            self.resetPasswordUrl = RESET_PASSWORD_URL
        }
        
        if let returnOptEast = values.return_opt_east , !returnOptEast.isEmpty
        {
            self.returnOptEast = returnOptEast
        }else{
            self.returnOptEast = RETURN_OPT_EAST
        }
        
        if let returnOptWest = values.return_opt_west , !returnOptWest.isEmpty
        {
            self.returnOptWest = returnOptWest
        }else{
            self.returnOptWest = RETURN_OPT_WEST
        }
        
        if let suppressExtender = values.extender_suppress_interval, !suppressExtender.isEmpty {
            self.extenderSuppressInterval = suppressExtender
        } else {
            self.extenderSuppressInterval = EXTENDER_SUPPRESS_INTERVAL
        }
        
        if let grandFatheredText = values.grandfathered_text , !grandFatheredText.isEmpty
        {
            self.grandFatheredText = grandFatheredText
        } else {
            self.grandFatheredText = GRANDFATHERED_TEXT
        }
        
        if let grandFatheredLink = values.grandfathered_link , !grandFatheredLink.isEmpty
        {
            self.grandFatheredLink = grandFatheredLink
        } else {
            self.grandFatheredLink = GRANDFATHERED_LINK
        }
        
        if let grandFatheredButton = values.grandfathered_button , !grandFatheredButton.isEmpty
        {
            self.grandFatheredButton = grandFatheredButton
        } else {
            self.grandFatheredButton = GRANDFATHERED_BUTTON
        }
        
        if let maxLimitExceedButton = values.max_limit_exceeded_button , !maxLimitExceedButton.isEmpty
        {
            self.maxLimitExceedButton = maxLimitExceedButton
        } else {
            self.maxLimitExceedButton = MAX_LIMIT_EXCEED_BUTTON
        }
        
        if let maxLimitExceedText = values.max_limit_exceeded_text , !maxLimitExceedText.isEmpty
        {
            self.maxLimitExceedText = maxLimitExceedText
        } else {
            self.maxLimitExceedText = MAX_LIMIT_EXCEED_TEXT
        }
        
        // Share Feedback URL
        if let shareUrl = values.feedback_url, !shareUrl.isEmpty {
            self.feedbackURL = shareUrl
        } else {
            self.feedbackURL = FEEDBACK_URL
        }
          
        if let activeTempPassResetURL = values.active_temp_reset_password_url, !activeTempPassResetURL.isEmpty {
            self.activeTempResetPassUrl = activeTempPassResetURL
        } else {
            self.activeTempResetPassUrl = ACTIVE_TEMP_RESET_PASSWORD_URL
        }
        
        if let activeTempPassResetURL = values.active_temp_reset_password_url, !activeTempPassResetURL.isEmpty {
            self.activeTempResetPassUrl = activeTempPassResetURL
        } else {
            self.activeTempResetPassUrl = ACTIVE_TEMP_RESET_PASSWORD_URL
        }
        
        if let reAuthDurationSeconds = values.re_auth_duration_seconds, !reAuthDurationSeconds.isEmpty {
            self.reAuthDurationSeconds = reAuthDurationSeconds
        } else {
            self.reAuthDurationSeconds = RE_AUTH_DURATION_SECONDS
        }
        
        if let whats_new = values.whats_new, !whats_new.isEmpty {
            self.whats_new = whats_new
        }
        
        if let app_rating_value = values.app_rating_enabled, !app_rating_value.isEmpty {
            self.app_rating_enabled = app_rating_value
        } else {
            self.app_rating_enabled = APP_RATING_ENABLED
        }
        
        if let app_rating_days = values.app_rating_window_days, !app_rating_days.isEmpty {
            self.app_rating_window_days = app_rating_days
        } else {
            self.app_rating_window_days = APP_RATING_WINDOW_DAYS
        }
        
        if let ad_enabled =  values.ad_enabled, !ad_enabled.isEmpty {
            self.ad_enabled = ad_enabled
        }
        
        if let ad_id = values.ad_id, !ad_id.isEmpty {
            self.ad_id = ad_id
        }
        
        if let chat_support_enabled =  values.chat_support_enabled, !chat_support_enabled.isEmpty {
            self.chat_support_enabled = chat_support_enabled
        }
        
        if let asapp_app_id = values.asapp_app_id, !asapp_app_id.isEmpty {
            self.asapp_app_id = asapp_app_id
        }
        
        if let asapp_host = values.asapp_host, !asapp_host.isEmpty {
            self.asapp_host = asapp_host
        }
        
        if let service_restoration_window = values.service_restoration_window, !service_restoration_window.isEmpty {
            self.service_restoration_window = service_restoration_window
        }
        
    }
    
    func saveBackupValuesForConfig() {
        self.createUserIDURL = CREATE_USERID_URL
        self.forgotPasswordURL = FORGOT_PASSWORD_URL
        self.forgotUserIdURL = FORGOT_USERID_URL
        self.greetingScreenDisplayTime = GREETING_SCREEN_DISPLAY_TIME
        self.privacyPolicyURL = PRIVACY_POLICY_URL
        self.salutationGreetings = SALUTATION_GREETINGS
        self.tosURL = TOS_URL
        self.troubleShootingSupport = TROUBLESHOOTING_SUPPORT
        self.tosPpText  = TOS_PP_TEXT
        self.appUpdateUrl = APP_UPDATE_URL
        self.asmThresholdDuration = ASM_THRESHOLD_DURATION
        self.autopayTosURL = AUTOPAY_TOS_URL
        self.customerSupportOptEast = CUSTOMER_SUPPORT_OPT_EAST
        self.customerSupportOptWest = CUSTOMER_SUPPORT_OPT_WEST
        self.dnsManagement = DNS_MANAGEMENT
        self.lansetup = LAN_SETUP
        self.omnitureReportSuitId = OMNITURE_REPORT_SUIT_ID
        self.outageUrl = OUTAGE_URL
        self.paperlessTosUrl = PAPERLESS_TOS_URL
        self.portForwarding = PORT_FORWARDING
        self.portManagement = PORT_MANAGEMENT
        self.qoeThreshold = QOE_THRESHOLD
        self.deadSpotInterval = DEADSPOT_INTERVAL
        self.resetPasswordUrl = RESET_PASSWORD_URL
        self.returnOptEast = RETURN_OPT_EAST
        self.returnOptWest =  RETURN_OPT_WEST
        self.feedbackURL = FEEDBACK_URL
        self.reAuthDurationSeconds = RE_AUTH_DURATION_SECONDS
        self.whats_new = ""
        self.app_rating_enabled = APP_RATING_ENABLED
        self.app_rating_window_days = APP_RATING_WINDOW_DAYS
        self.ad_enabled = ""
        self.ad_id = GoogleAdaptiveBannerID
        self.chat_support_enabled = ""
        self.asapp_app_id = ""
        self.asapp_host = ""
        self.service_restoration_window = SERVICE_RESTORATION_WINDOW
        }
}
