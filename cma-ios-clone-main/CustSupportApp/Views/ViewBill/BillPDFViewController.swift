//
//  BillPDFViewController.swift
//  CustSupportApp
//
//  Created by vishali Test on 22/08/23.
//

import UIKit
import WebKit
import Lottie

class BillPDFViewController: UIViewController {
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    @IBOutlet weak var label_Title: UILabel!
//    @IBOutlet weak var label_SubTitle: UILabel!
    @IBOutlet weak var viewClose: UIView!
    @IBOutlet weak var button_DownloadPDF: CustomTapInset!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var viewBillInfo: UIView!
    @IBOutlet weak var viewBillingHistory: UIControl!
    //@IBOutlet weak var pdfViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewHeaderTopConstraint : NSLayoutConstraint!
    @IBOutlet weak var titleViewBottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleViewBillHistoryConstrint: NSLayoutConstraint!
//    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var supportView: UIView!
    
    var scrollByDragging : Bool = false
    var isUserTapped : Bool = false
    var isZoomedIn : Bool = false
    var pdfType: PdfType = .viewBill
    var initialViewHeaderHeight: Float = 0.0
    var initialZoomScale: Float = 1.0
    var needToRemovePDF: Bool = true
    var onlyContentScrollAllowed: Bool = false
    var lastContentOffset : CGFloat = 0.0
    var isSuddenVariationOccured: Bool = false
    var trackConsecutiveSuddenOffsetCount: Int = 0
    var qualtricsAction : DispatchWorkItem?
//    var fileName : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackEvents()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 1
        self.webView.scrollView.bounces = false
        self.webView.addGestureRecognizer(tapGesture)
        self.initialDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.webView.scrollView.isScrollEnabled = false
        self.webView.scrollView.contentOffset.y = 0.0
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if self.needToRemovePDF {
            self.initialUISetup()
            self.initiatePdfDownload()
        } else {
            if QuickPayManager.shared.isPdfFileAvailable(fileName: self.getPdfFileName() ?? "") {
                self.initialDelegates()
                self.validateAndLoadPdfUrl(fileName: self.getPdfFileName())
            } else {
                self.initialUISetup()
                self.initiatePdfDownload()
            }
        }
    }
    
    func addQualtrics(){
        self.qualtricsAction = self.checkQualtrics(screenName: BillingMenuDetails.BILLING_VIEW_BILL_PDF.rawValue, dispatchBlock:&qualtricsAction )
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qualtricsAction?.cancel()
    }
    private func IsPdfAvailableAlready() {
        switch pdfType {
        case .inserts(let pdfInfoDetails):
            guard pdfInfoDetails != nil else {
                return
            }
            if QuickPayManager.shared.isPdfFileAvailable(fileName: self.getPdfFileName() ?? "") {
//                self.loadingAnimation(start: false)
                self.validateAndLoadPdfUrl(fileName: self.getPdfFileName())
            } else {
                self.initiatePdfDownload()
            }
        default:
            self.initiatePdfDownload()
        }
    }
    
    private func initialDelegates() {
        self.webView.scrollView.delegate = self
        self.webView.navigationDelegate = self
    }
    
    private func checkScreenType() {
        // CMAIOS-2447
        if QuickPayManager.shared.isAccountManualBlocked() {
        self.viewBillingHistory.isHidden = true
        self.titleViewBottonConstraint.priority = UILayoutPriority(999)
        self.titleViewBottonConstraint.constant = 0.0
        self.titleViewBillHistoryConstrint.priority = UILayoutPriority(250)
        self.headerViewHeight.constant = 90.0
    }
    }
    
    private func initialUISetup() {
        self.button_DownloadPDF.isHidden = true
        self.addShadow()
        /*
         guard let dict = QuickPayManager.shared.modelQuickPayListBill?.billSummaryList?.last,
         let statementDate = dict.statementDate else {
         return
         }
         let formattedDate = CommonUtility.convertDateStringFormats(dateString: statementDate, dateFormat: "MMM. d, yyyy")
         self.label_Title.text = "Your \(formattedDate) bill"
         self.label_SubTitle.text = "This bill does not reflect credits or payments made after this statement was issued."
         */
        switch pdfType {
        case .viewBill:
            guard let dict = QuickPayManager.shared.modelQuickPayListBill?.billSummaryList?.last,
                  let statementDate = dict.statementDate else {
                return
            }
            let formattedDate = CommonUtility.convertDateStringFormats(dateString: statementDate, dateFormat: "MMM. d, yyyy")
            self.label_Title.text = "Your \(formattedDate) bill"
//            self.label_SubTitle.text = "This bill does not reflect credits or payments made after this statement was issued."
            self.loadingAnimation(start: true, documentAnimation: false)
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : BillingMenuDetails.BILLING_VIEW_BILL_PDF.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
            self.checkScreenType() // To validate Manual Block state
        case .inserts(let pdfInfoDetails):
            guard let pdfInfo = pdfInfoDetails else {
                return
            }
            self.viewBillingHistory.isHidden = true
//            self.label_SubTitle.isHidden = true
            self.titleViewBottonConstraint.priority = UILayoutPriority(999)
            self.titleViewBottonConstraint.constant = 0.0
            self.titleViewBillHistoryConstrint.priority = UILayoutPriority(250)
            self.headerViewHeight.constant = 75.0

            if let isBillInsert = pdfInfo.isBillInsert, isBillInsert == true {
                self.loadingAnimation(start: true, documentAnimation: true)
                self.label_Title.text = pdfInfo.title
                if(pdfInfo.title == "Rates & Packages"){
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : BillingMenuDetails.BILLING_VIEW_RATES_AND_PACKAGES.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
                }
                
            } else {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : BillingMenuDetails.BILLING_VIEW_BILL_PDF.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
                self.loadingAnimation(start: true, documentAnimation: false)
                if let dateString = pdfInfo.statementDate {
                    let formattedDate = CommonUtility.convertDateStringFormats(dateString: dateString, dateFormat: "MMM. d, yyyy")
                    self.label_Title.text = "Your \(formattedDate) bill"
                }
            }
        }
    }
    
    private func addShadow() {
        // Add Shadow to close button view
        let shadowPath = UIBezierPath(rect: CGRect(x: self.viewClose.bounds.origin.x, y: self.viewClose.bounds.origin.y, width: currentScreenWidth, height: self.viewClose.bounds.height))
        self.viewClose.layer.masksToBounds = false
        self.viewClose.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        self.viewClose.layer.shadowOffset = CGSizeMake(0.0, -5.0)
        self.viewClose.layer.shadowOpacity = 0.5
        self.viewClose.layer.shadowPath = shadowPath.cgPath
    }
    
    private func validateAndLoadPdfUrl(fileName: String?) {
//        guard  let filename = self.getPdfFileName(), let url = URL(string: filename) else {
//            return
//        }
       
        guard let url = URL(string: QuickPayManager.shared.getPdfFileUrl(fileName: self.getPdfFileName()) ?? "") else {
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func checkPdfContentToDisableScrolling() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.label_Title.text != "Rates & Packages"{
                self.addQualtrics()
            }
            self.loadingAnimation(start: false)
            self.button_DownloadPDF.isHidden = false
            self.webView.scrollView.isScrollEnabled = true
            if self.webView.scrollView.contentSize.height >= self.webView.frame.height {
                self.initialZoomScale = Float(self.webView.scrollView.zoomScale)
                self.onlyContentScrollAllowed = false
            } else {
                self.onlyContentScrollAllowed = true
            }
        }
    }
    
    private func getPdfFileName() -> String? {
        var fileName: String?
        switch pdfType {
        case .viewBill:
            fileName = QuickPayManager.shared.getFilename().1
        case .inserts(let pdfInfoDetails):
            guard let pdfInfo = pdfInfoDetails else {
                return fileName
            }
            if let isBillInsert = pdfInfo.isBillInsert, isBillInsert == true {
                if let title = pdfInfo.title, let dateStr = pdfInfo.statementDate {
                    fileName = "Optimum " + title + " " + CommonUtility.convertDateStringFormats(dateString: dateStr, dateFormat: "MMM yyyy")
                }
            } else {
                if let dateStr = pdfInfo.statementDate {
                    fileName = "Optimum Bill " + CommonUtility.convertDateStringFormats(dateString: dateStr, dateFormat: "MMM yyyy")
                }
            }
        }
        return fileName
    }
    
    @objc func handleTap() {
        //Execute tapGesture when the user is not scrolling the PDF and also not zooming in the PDF
        if self.viewHeaderTopConstraint.constant != 0 && !scrollByDragging && !isZoomedIn {
            isUserTapped = true
            isSuddenVariationOccured = true
            UIView.animate(withDuration: 0.3) {
                self.viewHeaderTopConstraint.constant = 0
//                self.viewHeader.alpha = self.getFadingEffect(offsetValue: self.viewHeaderTopConstraint.constant)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func getFadingEffect(offsetValue:CGFloat) -> CGFloat{
        switch offsetValue {
        case (-10)...(-5):
            return 0.8
        case (-30)...(-10):
            return 0.7
        case (-60)...(-30):
            return 0.5
        case (-120)...(-60):
            return 0.4
        case (-300)...(-120):
            return 0.3
        default :
            return 1.0
        }
    }
    
    /*func animateHeaderViewDownward() {
        UIView.animate(withDuration: 0.3) {
            self.headerViewHeight.constant = CGFloat(self.initialViewHeaderHeight)
            self.viewHeader.frame.origin.y = UIDevice.current.hasNotch ? UIDevice.current.topInset - 6.0 : 20
            self.view.layoutIfNeeded()
        }
    }
    
    func animateHeaderViewUpward() {
        UIView.animate(withDuration: 0.3) {
            self.headerViewHeight.constant = 0
            self.viewHeader.frame.origin.y = CGFloat(-self.initialViewHeaderHeight)
            self.view.layoutIfNeeded()
        }
    }*/
    
    @IBAction func onClickCloseButton(_ sender: Any) {
        self.qualtricsAction?.cancel()
        if let _ = self.navigationController?.viewControllers.filter({$0.isKind(of: PaymentHistoryViewController.classForCoder())}).first {
            self.navigationController?.popViewController(animated: true)
        } else if let _ = self.navigationController?.viewControllers.filter({$0.isKind(of: BillingPaymentViewController.classForCoder())}).first {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.dismiss(animated: true, completion: {
                switch self.pdfType {
                case .viewBill:
                    QuickPayManager.shared.removePdfFile()
                default: break
                }
            })
        }
    }
    
    @IBAction func onClickDownloadPDFButton(_ sender: Any) {
        DispatchQueue.main.async {
            guard let pdfPath = QuickPayManager.shared.getPdfFileUrl(fileName: self.getPdfFileName()), let urlPath = URL(string: pdfPath) else {
                return
            }
            self.sharePDF(pdfPath: urlPath)
        }
    }
    
    func sharePDF(pdfPath: URL) {
        let activityViewController = UIActivityViewController(activityItems: [pdfPath], applicationActivities: nil)
        /*
        activityViewController.completionWithItemsHandler = { [weak self] (_, _, _, _) in
            if let downloadedPDFURL = QuickPayManager.shared.getPdfFileUrl(fileName: QuickPayManager.shared.getFilename().1), let urlPath = URL(string: downloadedPDFURL) {
                // Delete the downloaded PDF if the user has cancelled sharing on tapping cross button
                do {
//                    try FileManager.default.removeItem(at: urlPath)
                    Logger.info("Downloaded PDF deleted")
                } catch {
                    Logger.info("Error deleting downloaded PDF: \(error.localizedDescription)")
                }
            }
        }
        */
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func initiatePdfDownload() {
        switch pdfType {
        case .viewBill:
            guard let name = QuickPayManager.shared.getFilename().0, let fileName =  QuickPayManager.shared.getFilename().1 else {
                return
            }
            QuickPayManager.shared.removePdfFile()
            self.downloadOperation(name: name, fileName: fileName)
        case .inserts(let pdfInfoDetails):
            guard let pdfInfo = pdfInfoDetails else {
                return
            }
            if let isBillInsert = pdfInfo.isBillInsert, isBillInsert == true {
                if let title = pdfInfo.title, let dateStr = pdfInfo.statementDate {
                    let fileName = "Optimum " + title + " " + CommonUtility.convertDateStringFormats(dateString: dateStr, dateFormat: "MMM yyyy")
                    self.downloadOperation(name: pdfInfo.pdfName ?? "", fileName: fileName)
                }
            } else {
                if let dateStr = pdfInfo.statementDate {
                    let fileName = "Optimum Bill " + CommonUtility.convertDateStringFormats(dateString: dateStr, dateFormat: "MMM yyyy")
                    self.downloadOperation(name: pdfInfo.pdfName ?? "", fileName: fileName)
                }
            }
        }
        /*
         if QuickPayManager.shared.isPdfFileAvailable(fileName: fileName) {
         self.loadingAnimation(start: false)
         self.validateAndLoadPdfUrl(fileName: fileName)
         } else {
         self.downloadOperation(name: name, fileName: fileName)
         }
         */
    }
        
    private func downloadOperation(name: String, fileName: String) {
        var isBillInsert: Bool = false
        switch pdfType {
        case .viewBill:
            isBillInsert = false
        case .inserts(let pdfInfoDetails):
            if let pdfInfo = pdfInfoDetails, let billInsert = pdfInfo.isBillInsert {
                isBillInsert = billInsert
            }
        }
        QuickPayManager.shared.downloadBillPdf(name: name, fileName: fileName, isBillInsert: isBillInsert) { success in
            DispatchQueue.main.async {
//                self.loadingAnimation(start: false)
                if success {
                    self.validateAndLoadPdfUrl(fileName: fileName)
                } else {
                    self.loadingAnimation(start: false)
                    Logger.info("Pdf download failed")
                    self.navigateToErrorScreen()
                }
            }
        }
    }
    
    private func navigateToErrorScreen() {
        self.qualtricsAction?.cancel()
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = .billingApiFailure(type: .billApiError)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.pushViewController(viewcontroller, animated: false)
    }
        
    private func loadingAnimation(start: Bool, documentAnimation: Bool = false) {
        switch start {
        case true:
            self.loadingAnimationView.isHidden = true
            self.supportView.isHidden = true
            self.webView.isHidden = true
            UIView.animate(withDuration: 1.0) {
                self.loadingAnimationView.isHidden = false
                self.supportView.isHidden = false
            }
            self.loadingAnimationView.backgroundColor = .clear
            self.loadingAnimationView.animation = documentAnimation ? LottieAnimation.named("LoadingDoc"): LottieAnimation.named("LoadingBill")
            self.loadingAnimationView.loopMode = .loop
            self.loadingAnimationView.animationSpeed = 1.0
            self.loadingAnimationView.play()
        case false:
            self.loadingAnimationView.isHidden = true
            self.supportView.isHidden = true
            self.webView.isHidden = false
            self.loadingAnimationView.stop()
        }
    }
    
    @IBAction func viewBillPaymentHistory(_ sender: Any) {
        self.qualtricsAction?.cancel()
        guard let viewcontroller = PaymentHistoryViewController.instantiateWithIdentifier(from: .billing) else { return }
        self.needToRemovePDF = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    private func trackEvents() {
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_VIEW_MY_BILL_NEW_LANDING.rawValue,
                        EVENT_SCREEN_CLASS: self.classNameFromInstance])
        if QuickPayManager.shared.isAccountManualBlocked() {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : PaymentScreens.MANUAL_BLOCK_VIEW_BILL.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
        }
    }
}

extension BillPDFViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension BillPDFViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch onlyContentScrollAllowed {
        case false:
            self.manageDidScroll(scrollView: scrollView)
        case true: break
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !isZoomedIn { // to avoid mix of zoomed in/out with scrolling of webView
            scrollByDragging = true // tells user has started scrolling the screen
            isUserTapped = false // tells whether the user taps the screen
            isZoomedIn = false // tells whether the user has zoomed in/out
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollByDragging = false // user has ended scrolling the screen
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
          scrollByDragging = false
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        isZoomedIn = true
        isUserTapped = false
        scrollByDragging = false
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat)
    {
        isZoomedIn = false
    }
    
    private func manageDidScroll(scrollView: UIScrollView) {
        let scroll = String(format: "%.3f", scrollView.zoomScale)
        let scrollinitial = String(format: "%.3f", self.initialZoomScale)
        guard let currentZoomScale = Float(scroll), let initalScrollZoomScale = Float(scrollinitial) else {
            return
        }
        if currentZoomScale <= initalScrollZoomScale  && !isZoomedIn {
            if !isUserTapped {
                if (lastContentOffset > scrollView.contentOffset.y && lastContentOffset < scrollView.contentSize.height - scrollView.frame.height){
                    // user is scrolling up the pdf view
                    // Moving from last page towards first page
                    let difference = lastContentOffset - scrollView.contentOffset.y
                    handlePDFUpwardScroll(contentOffset: difference)
                    
                } else if lastContentOffset < scrollView.contentOffset.y && scrollView.contentOffset.y > 0 {
                    // user is scrolling down the pdf view
                    // Moving from first page towards last page
                    var difference = scrollView.contentOffset.y - lastContentOffset
                    difference = handleSuddenChangeInContentOffset(contentOffset: difference)
                    handlePDFDownwardScroll(contentOffset: difference)
                } else if lastContentOffset == 0.0 || (lastContentOffset > scrollView.contentSize.height - scrollView.frame.height)  {
                    // user is scrolling up the pdf view
                    // Moving from last page towards first page
                    let difference = lastContentOffset - scrollView.contentOffset.y
                    handlePDFUpwardScroll(contentOffset: difference)
                }
                lastContentOffset = scrollView.contentOffset.y
            }
        }
    }
    
    // Handle PDF scrolling while scrolling upwards
    func handlePDFUpwardScroll(contentOffset: CGFloat) {
         if (self.viewHeaderTopConstraint.constant + contentOffset) <= 0 {
             if (self.lastContentOffset <= 1.0  && self.webView.scrollView.contentOffset.y <= 1.0) || self.lastContentOffset == 0.0 {
                 //Fix added for slight jump issue observed for Rates & Packages
                 UIView.animate(withDuration: 0.3) {
                     self.viewHeaderTopConstraint.constant = 0
                     self.view.layoutIfNeeded()
                     return
                 }
             } else {
                 self.viewHeaderTopConstraint.constant = self.viewHeaderTopConstraint.constant + contentOffset
             }
         } else {
             self.viewHeaderTopConstraint.constant = 0
         }
         
         UIView.animate(withDuration: 0.01) {
             // Adding fade effect
//             self.viewHeader.alpha = self.getFadingEffect(offsetValue: self.viewHeaderTopConstraint.constant)
             self.view.layoutIfNeeded()
         }
    }
    
    // Handle PDF scrolling while scrolling downwards
    func handlePDFDownwardScroll(contentOffset: CGFloat) {
        if self.viewHeaderTopConstraint.constant >= getMinimumTopConstraintValue() {
            self.viewHeaderTopConstraint.constant = self.viewHeaderTopConstraint.constant - contentOffset
            //set minimum value of topConstraint as per header height
            if self.viewHeaderTopConstraint.constant <= self.getMinimumTopConstraintValue(){
                self.viewHeaderTopConstraint.constant = self.getMinimumTopConstraintValue()
            }
            UIView.animate(withDuration: 0.01) {
//                self.viewHeader.alpha = self.getFadingEffect(offsetValue: self.viewHeaderTopConstraint.constant)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // Handle sudden variation in contentoffset for header view animation
    func handleSuddenChangeInContentOffset(contentOffset: CGFloat) -> CGFloat {
        if isSuddenVariationOccured {
            if contentOffset >= 0 && trackConsecutiveSuddenOffsetCount <= 3 {
                trackConsecutiveSuddenOffsetCount = trackConsecutiveSuddenOffsetCount + 1
                return 0.0
            }
        }
        isSuddenVariationOccured = false
        trackConsecutiveSuddenOffsetCount = 0
        return contentOffset
    }
    
    func getMinimumTopConstraintValue()-> CGFloat{
        switch self.pdfType {
        case .viewBill:
            return -160.0 //headerHeight + 50.0
        case .inserts(pdfInfo: _):
            return -120.0 //headerHeight + 50.0
        }
    }
}

extension BillPDFViewController: WKNavigationDelegate {
    // This method is called when the web view finishes loading a page
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //        self.button_DownloadPDF.isHidden = false
        self.checkPdfContentToDisableScrolling()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let urlString = navigationAction.request.url?.absoluteString else {
            return .cancel
        }
        if urlString.contains(self.getPdfFileName()?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? "") {
            return .allow
        }
        return .cancel
    }
}

enum PdfType {
    case inserts(pdfInfo: PdfInfo?)
    case viewBill
}

struct PdfInfo {
    let isBillInsert: Bool?
    let statementDate: String?
    let pdfName: String?
    let title: String?
}
