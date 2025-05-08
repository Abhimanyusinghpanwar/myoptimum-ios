//
//  CreditCardScanner.swift
//  test4
//
//  Created by Jason Melvin Ready on 6/28/22.
//

import UIKit
import AVFoundation
import Vision

class CreditCardScanner: BaseViewController, BarButtonItemDelegate, AVCaptureVideoDataOutputSampleBufferDelegate{
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.captureSession.stopRunning() // CMAIOS-1244
            self.navigationController?.popViewController(animated: true)
        } else {
            cancelButtonTapped()
        }
    }
    
    @IBOutlet weak var labelCardNumber: UILabel!
    @IBOutlet weak var labelCardExpiry: UILabel!
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var scannerView2: UIView!
    @IBOutlet weak var scannerView1: UIView!
    @IBOutlet weak var topLeft: UIImageView!
    @IBOutlet weak var topRight: UIImageView!
    @IBOutlet weak var bottomLeft: UIImageView!
    @IBOutlet weak var bottomRight: UIImageView!
    public var completionHandler : ((String, String)->Void)?
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = .resizeAspectFill
        return preview
    }()
    private let device = AVCaptureDevice.default(for: .video)
    private var creditCardNumber:String?
    private var creditCardDate:String?
    private var creditCardType:CreditCardType?
    var navigatedToCardInfo = false
    var scannerDelay = 0
    var flow: flowType = .addCard(navType: .home)
    var isMakePaymentFlow: Bool = false
    var schedulePaymentDate: String?
    
    var screenBounds: CGRect?
    var scannerView1frame: CGRect?
    var scannerView2frame: CGRect?
    var selectedAmount: Double = 0.0
    var isAutoPaymentErrorFlow = false


    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonDelegate = self
        self.checkCamerPermission()
        self.initalUISetup()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideUIComponentsOnNavigation()
        self.stopCameraSession()
    }
    
    private func initalUISetup() {
        self.scannerView2.bringSubviewToFront(self.labelCardExpiry)
        self.scannerView2.bringSubviewToFront(self.labelCardNumber)
    }
    
    private func checkCamerPermission() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            setupCaptureSession()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                }
                else {
                    Logger.info("Camera access not granted for card scanning")
                }
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigatedToCardInfo = false
        self.creditCardNumber = nil
        self.creditCardDate = nil
        DispatchQueue.main.async { // CMAIOS-1244
            self.topLeft.image = UIImage(named: "topLeft")
            self.topRight.image = UIImage(named: "topRight")
            self.bottomLeft.image = UIImage(named: "bottomLeft")
            self.bottomRight.image = UIImage(named: "bottomRight")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now()) { // CMAIOS-1244
            DispatchQueue.main.async {
                self.screenBounds = UIScreen.main.bounds
                self.scannerView1frame = self.scannerView1.bounds
                self.scannerView2frame = self.scannerView2.bounds
            }
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.previewLayer.isHidden = false
            }
        }
    }
    
    func stopCameraSession() {
        self.captureSession.stopRunning()
    }
    
    @objc func cancelButtonTapped() {
        self.captureSession.stopRunning() // CMAIOS-1244
        //CMAIOS-2099
        if let billPreferenceVC = self.navigationController?.viewControllers.filter({$0 is BillingPreferencesViewController}).first as? BillingPreferencesViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(billPreferenceVC, animated: true)
            }
        } else if let vc = self.navigationController?.viewControllers.filter({$0 is SetUpAutoPayPaperlessBillingVC}).first as? SetUpAutoPayPaperlessBillingVC { //CMAIOS-2882
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(vc, animated: true)
            }
        } else if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
            self.dismiss(animated: true)
        } else if let managedPaymentController = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(managedPaymentController, animated: true)
            }
        } else if let billingPayController = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(billingPayController, animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        //
    }
    
    func setupCaptureSession() {
        guard let tempDevice = device else { return }
        let cameraInput = try! AVCaptureDeviceInput(device: tempDevice)
        captureSession.addInput(cameraInput)
        let rootLayer :CALayer = self.scannerView1.layer
        rootLayer.masksToBounds = true
        previewLayer.frame = CGRect.zero
        rootLayer.addSublayer(self.previewLayer)
//        view.layer.addSublayer(previewLayer)
        //        self.scannerView1.layer.zPosition = 1
        //        view.bringSubviewToFront(scannerView1)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "CreditCardScannerQueue"))
        captureSession.addOutput(videoOutput)
        if let connection = videoOutput.connection(with: AVMediaType.video), connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.extractCreditCardData(capturedFrame: frame)
        }
    }
    
    func extractCreditCardData(capturedFrame: CVImageBuffer) {
        var recognizedText = [String]()
        var textRecognitionRequest = VNRecognizeTextRequest()
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.usesLanguageCorrection = false
        textRecognitionRequest.customWords = CardType.allCases.map { $0.rawValue } + ["Expiry Date"]
        textRecognitionRequest = VNRecognizeTextRequest() { (request, error) in
            guard let results = request.results,
                  !results.isEmpty,
                  let requestResults = request.results as? [VNRecognizedTextObservation]
            else { return }
            recognizedText = requestResults.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }
        }
        
        let cropperImage = getCroppedImage(frame: capturedFrame)
        
//        let ciImage = CIImage(cvImageBuffer: capturedFrame)
        let handler = VNImageRequestHandler(ciImage: cropperImage, options: [:])
        do {
            try handler.perform([textRecognitionRequest])
            let printDetails = parseResults(for: recognizedText)
//            if let creditCardDate = printDetails.expireDate, let creditCardNumber = printDetails.number, let name = printDetails.name {
            if let creditCardDate = printDetails.expireDate, let creditCardNumber = printDetails.number {
                scannerDelay += 1
                if !self.navigatedToCardInfo && scannerDelay > 3 {
                    DispatchQueue.main.async {
                        self.labelCardExpiry.isHidden = false
                        self.labelCardNumber.isHidden = false
                        self.labelCardNumber.text = creditCardNumber
                        self.labelCardExpiry.text = creditCardDate
                        self.topLeft.image = UIImage(named: "topLeftBlue")
                        self.topRight.image = UIImage(named: "topRightBlue")
                        self.bottomLeft.image = UIImage(named: "bottomLeftBlue")
                        self.bottomRight.image = UIImage(named: "bottomRightBlue")
//                        self.navigatedToCardInfo = true
                        if let cardType = CreditCardValidator.cardType(cardNumber: creditCardNumber) {
//                            let cardName = name.withoutSpecialCharacters
                            let cardName = ""
                            let image = cardType.cardImage
                            let cardInfo = CardInfo(cardNumber: creditCardNumber, cardImage: image, cardName: cardName, expirationDate: creditCardDate)
                            Logger.info(cardName, sendLog: "Card Name")
                            self.showManualCardEntryWithScannedInfo(cardInfo: cardInfo)
                        }
                    }
                    self.stopCameraSession() // CMAIOS-1244
                } else {
                    if scannerDelay > 3 {
                        self.stopCameraSession()
                    }
                }
            }
        } catch {
            Logger.info("Error in scanned card data - \(error)")
            self.stopCameraSession()
        }
        
        /*
         //        DispatchQueue.main.async {
         let ciImage = CIImage(cvImageBuffer: capturedFrame)
         //            let width = width
         //            let height = height
         let viewX = (UIScreen.main.bounds.width / 2) - (scannerSize.width / 2) + 7
         let viewY = (UIScreen.main.bounds.height / 2) - (scannerSize.height / 2) + scannerSize.height
         
         let resizeFilter = CIFilter(name: "CILanczosScaleTransform")!
         
         // Desired output size
         let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
         
         // Compute scale and corrective aspect ratio
         let scale = targetSize.height / ciImage.extent.height
         let aspectRatio = targetSize.width / (ciImage.extent.width * scale)
         
         // Apply resizing
         resizeFilter.setValue(ciImage, forKey: kCIInputImageKey)
         resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
         resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
         let outputImage = resizeFilter.outputImage
         
         let croppedImage = outputImage!.cropped(to: CGRect(x: viewX, y: viewY, width: scannerSize.width, height: scannerSize.height))
         
         let request = VNRecognizeTextRequest()
         request.recognitionLevel = .accurate
         request.usesLanguageCorrection = false
         
         let stillImageRequestHandler = VNImageRequestHandler(ciImage: croppedImage, options: [:])
         try? stillImageRequestHandler.perform([request])
         
         guard let texts = request.results, texts.count > 0 else {
         // no text detected
         return
         }
         
         let arrayLines = texts.flatMap({ $0.topCandidates(20).map({ $0.string }) })
         for line in arrayLines {
         print(" arrayLines Line -->", line)
         if self.creditCardNumber != nil && self.creditCardDate != nil{
         break
         }
         let trimmed = line.replacingOccurrences(of:" ", with: "")
         if self.creditCardNumber == nil && trimmed.count >= 15 && trimmed.count <= 19 && trimmed.isOnlyNumbers {
         //card number is the correct number of digits and is only numbers. Now check if it is valid
         if CreditCardValidator.isValidNumber(cardNumber: trimmed){
         self.creditCardNumber = trimmed
         continue
         }
         }
         if self.creditCardDate == nil{
         let last5Characters = String(trimmed.suffix(5))
         if last5Characters.isDate {
         self.creditCardDate = last5Characters
         continue
         }
         let last7Characters = String(trimmed.suffix(7))
         if last7Characters.isDate{
         self.creditCardDate = last7Characters
         continue
         }
         }
         }
         if let creditCardDate = self.creditCardDate, let creditCardNumber = self.creditCardNumber {
         if !self.navigatedToCardInfo {
         DispatchQueue.main.async {
         self.topLeft.image = UIImage(named: "topLeftBlue")
         self.topRight.image = UIImage(named: "topRightBlue")
         self.bottomLeft.image = UIImage(named: "bottomLeftBlue")
         self.bottomRight.image = UIImage(named: "bottomRightBlue")
         self.navigatedToCardInfo = true
         //                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
         print("ASASAS",creditCardDate,creditCardNumber)
         if let cardType = CreditCardValidator.cardType(cardNumber: creditCardNumber) {
         let cardName = cardType.cardName
         let image = cardType.cardImage
         let cardInfo = CardInfo(cardNumber: creditCardNumber, cardImage: image, cardName: cardName, expirationDate: creditCardDate)
         Logger.info(cardName)
         self.captureSession.stopRunning()
         self.showManualCardEntryWithScannedInfo(cardInfo: cardInfo)
         }
         }
         //                    }
         } else {
         self.captureSession.stopRunning()
         }
         }
         //        }
         */
    }
    
    private func getCroppedImage(frame: CVImageBuffer) -> CIImage {
        guard let scannerView1 = scannerView1frame, let screenBound = screenBounds, let scannerView2 = scannerView2frame else {
            return CIImage()
        }
        let ciImage = CIImage(cvImageBuffer: frame)
        let width = scannerView2.width
        let height = scannerView2.height
        let viewX = (screenBound.width / 2) - (width / 2)
        let viewY = (screenBound.height / 2) - (height / 2) + height + 140 // Padding
        
        let resizeFilter = CIFilter(name: "CILanczosScaleTransform")!
        
        // Desired output size
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        // Compute scale and corrective aspect ratio
        let scale = targetSize.height / ciImage.extent.height
        let aspectRatio = targetSize.width / (ciImage.extent.width * scale)
        
        // Apply resizing
        resizeFilter.setValue(ciImage, forKey: kCIInputImageKey)
        resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
        resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        let outputImage = resizeFilter.outputImage
        
        let croppedImage = outputImage!.cropped(to: CGRect(x: viewX, y: CGFloat(viewY), width: width, height: height))
        return croppedImage
    }
    
    func showManualCardEntryWithScannedInfo(cardInfo: CardInfo?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { // CMAIOS-1244
            if !self.navigatedToCardInfo {
                self.hideUIComponentsOnNavigation()
                self.navigatedToCardInfo = true
                self.stopCameraSession()
                self.navigateToCardInfoScreen(cardInfo: cardInfo)
            }
        }
    }
    
    private func navigateToCardInfoScreen(cardInfo: CardInfo?) {
        guard let viewcontroller = ManualCardEntryViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.cardInfo = cardInfo
        viewcontroller.flow = self.flow
        viewcontroller.isMakePaymentFlow = isMakePaymentFlow
        viewcontroller.schedulePaymentDate = schedulePaymentDate
        viewcontroller.selectedAmount = selectedAmount
        viewcontroller.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    private func hideUIComponentsOnNavigation() {
        self.previewLayer.isHidden = true
        self.labelCardExpiry.isHidden = true
        self.labelCardNumber.isHidden = true
    }
    
    func parseResults(for recognizedText: [String]) -> CreditCardDetails {
        // Credit Card Number
        var creditNumber: String?
        let creditCardNumber = recognizedText.first(where: { $0.count >= 14 && ["4", "5", "3", "6"].contains($0.first) })
        if let number = creditCardNumber {
            let trimmedNumber = number.replacingOccurrences(of:" ", with: "")
            if CreditCardValidator.isValidNumber(cardNumber: trimmedNumber) {
                creditNumber = trimmedNumber
            }
        }
        
        // Expiry Date
        let expiryDateString = recognizedText.first(where: { $0.count > 4 && $0.contains("/") })
        let expiryDate = expiryDateString?.filter({ $0.isNumber || $0 == "/" }) as? String
        var finalDate: String?

        if let dateValidation = expiryDate {
            let last5Characters = String(dateValidation.suffix(5))
            if last5Characters.isDate {
                finalDate = last5Characters
            } else {
                let last7Characters = String(dateValidation.suffix(7))
                if last7Characters.isDate {
                    finalDate = last7Characters
                }
            }
            finalDate = getFormattedDate(date: finalDate)
        }
        
        // Name
        let ignoreList = ["GOOD THRU", "GOOD", "THRU", "Gold", "GOLD", "Standard", "STANDARD", "Platinum", "PLATINUM", "WORLD ELITE", "WORLD", "ELITE", "World Elite", "World", "Elite", "Corporate", "DEBIT", "platinum", "Unlimited", "CardMember", "Card Member", "Since", "Chase", "MasterCard", "Visa", "Amex", "Diner's Club/Carte Blanche", "Discover", "Mastercard"]

        let wordsToAvoid = [creditCardNumber, expiryDateString] +
            ignoreList + convertIntoInCaseStrings(input: ignoreList)
        
        let name = recognizedText.filter({ !wordsToAvoid.contains($0) }).last
        return CreditCardDetails(number: creditNumber, name: name, expireDate: finalDate)
    }
    
    private func convertIntoInCaseStrings(input: [String]) -> [String] {
        let ignoreListUpperCase = input.map{ $0.uppercased() }
        let ignoreListLowerCase = input.map{ $0.lowercased() }
        return ignoreListUpperCase + ignoreListLowerCase
    }
    
    /// Modify the year format from YYYY to YY
    /// - Parameter date: Scanned Date
    /// - Returns: formated date (YY or nil)
    private func getFormattedDate(date: String?) -> String? {
        guard let dateStr = date else {
            return date
        }
        let arrayDate = dateStr.components(separatedBy: "/")
        if String(arrayDate[1]).count > 2 {
            let year = String(arrayDate[1]).getTrimmedString(isPrefix: true, length: 2)
            let formDate = String(arrayDate[0]) + "/" + year
            return formDate
        }
        return date
    }
    
}

private extension String {
    var isOnlyAlpha: Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }

    var isOnlyNumbers: Bool {
        return !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
    }

    // Date Pattern MM/YY or MM/YYYY
    var isDate: Bool {
        let arrayDate = components(separatedBy: "/")
        if arrayDate.count == 2 && arrayDate[0].isOnlyNumbers && arrayDate[1].isOnlyNumbers {
            if let month = Int(arrayDate[0]) {
                let validMonth = month <= 12 && month >= 1
                let validYear = arrayDate[1].count == 2 || arrayDate[1].count == 4
                return validMonth && validYear
            }
        }
        return false
    }
    
    var hasSpecialCharacters: Bool {
        do {
            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: .caseInsensitive)
            if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.count)) {
                return true
            }
        } catch {
            return false
        }

        return false
    }
}

public struct CreditCardDetails {
    var number: String?
    var name: String?
    var expireDate: String?
}
