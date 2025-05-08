//
//  CCEncryptUtility.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 13/05/22.
//

import Foundation
import CommonCrypto

class CCEncryptUtility {
    
    func aesEncryptOnly(_ plainText:String?) -> String {
        //validate input
        guard plainText != nil else {
            return ""
        }
        guard plainText != "" else {
            return ""
        }
        
        //start encryption process
        if let data:Data = plainText!.data(using: String.Encoding.utf8) {
            
            var arrKey: [UInt8] = [67,77,65,105,79,83,45,65,108,116,105,99,101,85,83,65]//Array("CMAiOS-AlticeUSA".utf8)
            
            //shift for static key
            for index in 0..<arrKey.count {
                arrKey[index] = arrKey[index]>>1
            }
            let cryptData = NSMutableData(length: Int(data.count) + kCCBlockSizeAES128)!
            
            let keyLength = size_t(kCCKeySizeAES128)
            let operation:CCOperation = UInt32(kCCEncrypt)
            let algoritm:CCAlgorithm = UInt32(kCCAlgorithmAES128)
            let options:CCOptions = UInt32(kCCOptionPKCS7Padding)
            
            var numBytesEncrypted :size_t = 0
            
            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      arrKey, keyLength,
                                      nil,
                                      (data as NSData).bytes, data.count,
                                      cryptData.mutableBytes, cryptData.length,
                                      &numBytesEncrypted)
            
            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                
                let base64cryptString = cryptData.base64EncodedString(options: .lineLength64Characters)
                
                return base64cryptString
                
            } else {
                return ""
            }
        }
        return ""
    }
    
    func aesDecrypt(cryptedText:String?) -> String {
    //validate input
    guard cryptedText != nil else {
    return ""
    }
    guard cryptedText != "" else {
    return ""
    }
    
    //start encryption process
    if let data:NSData =  NSData(base64Encoded: cryptedText!, options:NSData.Base64DecodingOptions(rawValue: 0)) {
    
    var arrKey: [UInt8] = [67,77,65,105,79,83,45,65,108,116,105,99,101,85,83,65] //Array("CMAiOS-AlticeUSA".utf8)
    for i in 0..<arrKey.count {
    arrKey[i] = arrKey[i]>>1
    }
    
    let plainData = NSMutableData(length: Int(data.length))!
    
    let keyLength = size_t(kCCKeySizeAES128)
    let operation:CCOperation = UInt32(kCCDecrypt)
    let algoritm:CCAlgorithm = UInt32(kCCAlgorithmAES128)
    let options:CCOptions = UInt32(kCCOptionPKCS7Padding)
    
    var numBytesDecrypted :size_t = 0
    
    let decryptStatus = CCCrypt(operation,
    algoritm,
    options,
    arrKey, keyLength,
    nil,
    data.bytes, data.length,
    plainData.mutableBytes, plainData.length,
    &numBytesDecrypted)
    
    if UInt32(decryptStatus) == UInt32(kCCSuccess) {
    if let plainText1 = String(data: plainData as Data, encoding: String.Encoding.utf8) {
    let plainText2 = plainText1.trimmingCharacters(in: CharacterSet.controlCharacters)
    return plainText2
    }
    return ""
    
    } else {
    return ""
    }
    }
    return ""
    }
}
