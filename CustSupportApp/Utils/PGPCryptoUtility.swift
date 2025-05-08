//
//  CommonEncryption.swift
//  CustSupportApp
//
//  Created by raju.ramalingam on 05/12/22.
//

import Foundation
import ObjectivePGP

class PGPCryptoUtility {
    
    ///  Method used to encrypt payment card number
    /// - Parameter cardNumber: card number used for payment
    /// - Returns: encrypted string
    ///  Encryption Steps:
    ///     1) Convert the public key to Data
    ///     2) Get the first key from PGPKey array
    ///     3) Convert the cardNumber to Data
    ///     4) Use ObjectivePGP.encrypt(, addSignature: , using: )  for PGP encryption using the public key
    public static func cardEncryption(cardNumber: String) -> String? {
        var encryptedString: String?
        guard let publicKeyData = CertificateKeys.CMA_Cert.data(using: String.Encoding.utf8),
              let publicKeys = (try? ObjectivePGP.readKeys(from: publicKeyData)) else {
            return encryptedString
        }
//        guard let publicKeyData = CertificateKeys.Test_Public.data(using: String.Encoding.utf8), // Use this for testing
//              let publicKeys = (try? ObjectivePGP.readKeys(from: publicKeyData)) else {
//            return encryptedString
//        }
        guard let firstPublicKey = publicKeys.first else { return encryptedString }
        guard let data = cardNumber.data(using: String.Encoding.utf8) else { return  encryptedString }
        do {
            let encryptedData = try ObjectivePGP.encrypt(data, addSignature: false, using: [firstPublicKey])
            encryptedString = Armor.armored(encryptedData, as: .message)
            //            self.cardDecrytion(encryptedMessage: encryptedString) /* Use this line for validating the decryption */
        } catch let error {
            Logger.info("Encryption Failed with,\(String(describing: error))")
        }
        return encryptedString
    }
    
    /*
     ///  Method used to decrypt encrypted message
     /// - Parameter encryptedMessage: encrypted message to be decrypted
     /// - Returns: decrypted card number
     public static func cardDecrytion(encryptedMessage: String) -> String? {
     var decryptedString: String?
     guard let publicKeyData = CertificateKeys.CMA_Cert.data(using: String.Encoding.utf8),
     let PrivateKeyData = CertificateKeys.CMA_Cert.data(using: String.Encoding.utf8) else {
     return decryptedString
     }
     guard let publicKeys = (try? ObjectivePGP.readKeys(from: publicKeyData)),
     let secretKeys = (try? ObjectivePGP.readKeys(from: PrivateKeyData)) else {
     return decryptedString
     }
     guard let firstPublicKey = publicKeys.first, let firstSecretKey = secretKeys.first else { return decryptedString }
     guard let data = encryptedMessage.data(using: String.Encoding.utf8) else { return  decryptedString }
     do {
     let decryptData = try ObjectivePGP.decrypt(data, andVerifySignature: false, using: [firstPublicKey, firstSecretKey])
     decryptedString = String(data: decryptData, encoding: .utf8)
     } catch let error {
     print("Decryption Failed with", error)
     }
     return decryptedString
     }
     */
}

struct CertificateKeys {
    static let CMA_Cert: String = "-----BEGIN PGP PUBLIC KEY BLOCK-----\n" +
    "Version: BCPG v1.52\n" +
    "\n" +
    "mQENBFZGTI8DCACfFYZmVrkiKzQjR0zBtz42OL6Hr4I+0/iHvujxw+vOxA/G7Cy0\n" +
    "+28E7/5RgGG1CYJXYEceQEsHyvpEa8ezEzU//aNh6S3FJVM8C7WyWHcmyh4m8IKO\n" +
    "UGYV0SCyVrz0rGQu+xQu3cvtjBvQ4IL4DIzjR9SoQw0zT+Vp9Gg4yFHSXeCVhqI/\n" +
    "NIqOtmcNWK/kVBT71k/aQ/NVKtrRKAJIIw22WvGfnNQaLdSWEeTo7NzcsZZd7aDU\n" +
    "s6zvf5rS2YQvIr9XOq709VM8RbfC14lpAAF1leANGuHnxV9p8EcskmGAH4pslSbs\n" +
    "4FVNgex88OnC1IA9LqsDjER4lJx3/qNI3T0pABEBAAG0FWViaWxsQGNhYmxldmlz\n" +
    "aW9uLmNvbYkBKAQTAwIAEgUCVkZMnAIbAwKLCQKVCAIeAQAKCRBp0tizpepmNDCJ\n" +
    "CACBQATvN7NKhc9MomFreNGcbQuCfSEnE0U2v7yFbVaIMEI6RtHThxbt8A2+E5bw\n" +
    "sqUZ9f/FvOs+4Ivqk79K5MuVIQ+NKqBsi3brz2u2BxyR3SaXVpUlfn1Mt3K2Krga\n" +
    "vLRH9jz1OK0arwRrQkZMPB0N55Cb0kJlrl20jPjrPKVkXnNdomg/WP7+VaWsXUlt\n" +
    "tS/3IGsbqnoSpGRgqTg508y+l2bT8myYoaqjk9yEgpkzLMebNKcxfFa4kDdrjf1I\n" +
    "nHtBcr1CeMzhcvI7Ag+cNkowmIluRyWvcOM/twZaITt2QY6RggIixpR52zPp572X\n" +
    "oq7Nkhxh4AKYwzt9BK7mV8b5uQENBFZGTJwCCACl7z7R1rbiGQ0rA5aRinmSwR8C\n" +
    "boUoYtwwyTF9fvofoQfQyaiU0Z4LkTU+RJ0XLXFjyfQ/weEuLp+sDiDkzhbKxIha\n" +
    "6ZnBgaCUCXRsvPq/nb1fqJuxtLyZ8gmYxcCGQkuNNN0LNC5GChV+bhp/Zlra4WzW\n" +
    "EkjxXbKtKGBU1Vq0v14cMnd1JUXQTVn2brE3SuPkT7WUtTgCpfgoPdJKyep83vnc\n" +
    "FIKrJXw486haGU6T8xaZSA8rv/7fYK/+958CvqUsOrKqMhZMQhp8wQwUHGDLrvp7\n" +
    "2/1pGh6bmElCMnEtrWc1HQ6nMEykhed823W4LW9/j5cTMY8x80cOtSV422VXABEB\n" +
    "AAGJAR8EGAMCAAkFAlZGTJwCGwwACgkQadLYs6XqZjSCfQf/XYhTbLICW84LMFVe\n" +
    "6L/3FvW0jln8NVguP0jre8X/4lZVW6WfGx0AJKGwN0bmm+YxbJa0V8QK3TJrykuD\n" +
    "ThTD4bWQiEsDBllvXPuF30X8RAhGlb/AgSkksSMBri8ZOpRfD+FrJWMvnI30KFfY\n" +
    "jhWWTgu6Dc2irQtaTG1cmxaAIaFwiS/iQJYFWchHPhxPXZC4Oh4Xk/u2KphR8x0K\n" +
    "d70L8ibWpEOyocKd4+m+tCJiTs7wkmgvRgm8Ozw8qBV+PVlX/FbWTtHpMyTrZYLb\n" +
    "6xGsbnaOHtN8dpGYC0LARjXriUZ/g38OX6vL20Ko8QZgn/gHr4EGSa1K0+WJcCGa\n" +
    "1mSasg==\n" +
    "=Y9xj\n" +
    "-----END PGP PUBLIC KEY BLOCK-----\n"
    
    // The Below keys should be used only for Dev testing
    /*
    static let Test_Private = "-----BEGIN PGP PRIVATE KEY BLOCK-----\n" +
    "Version: PGPainless\n" +
    "Comment: 12E3 4F04 C66D 2B70 D16C  960D ACF2 16F0 F93D DD20\n" +
    "Comment: alice@pgpainless.org\n" +
    "\n" +
    "lFgEYksu1hYJKwYBBAHaRw8BAQdAIhUpRrs6zFTBI1pK40jCkzY/DQ/t4fUgNtlS\n" +
    "mXOt1cIAAP4wM0LQD/Wj9w6/QujM/erj/TodDZzmp2ZwblrvDQri0RJ/tBRhbGlj\n" +
    "ZUBwZ3BhaW5sZXNzLm9yZ4iPBBMWCgBBBQJiSy7WCRCs8hbw+T3dIBYhBBLjTwTG\n" +
    "bStw0WyWDazyFvD5Pd0gAp4BApsBBRYCAwEABAsJCAcFFQoJCAsCmQEAAOOTAQDf\n" +
    "UsRQSAs0d/Nm4YIrq+gU7gOdTJuf33f/u/u1nGM1fAD/RY7I3gQoZ0lWbvXVkRAL\n" +
    "Cu9cUJdvL7kpW1oYtYg21QucXQRiSy7WEgorBgEEAZdVAQUBAQdA60F84k6MY/Uy\n" +
    "BCZe4/WP8JDw/Efu5/Gyk8hcd3HzHFsDAQgHAAD/aC8DOOkK0XNVz2hkSVczmNoJ\n" +
    "Umog0PfQLRujpOTqonAQKIh1BBgWCgAdBQJiSy7WAp4BApsMBRYCAwEABAsJCAcF\n" +
    "FQoJCAsACgkQrPIW8Pk93SCd6AD/Y3LF2RvgbEaOBtAvH6w0ZBPorB3rk6dx+Ae0\n" +
    "GvW4E8wA+QHmgNo0pdkDxTl0BN1KC7BV1iRFqe9Vo7fW2LLfhlEEnFgEYksu1hYJ\n" +
    "KwYBBAHaRw8BAQdAPtqap21/zmVzxOHk++891/EZSNikwWkq9t0pmYjhtJ8AAP9N\n" +
    "m/G6nbiEB8mu/TkNnb7vdhSmLddL9kdKh0LzWD95LBF0iNUEGBYKAH0FAmJLLtYC\n" +
    "ngECmwIFFgIDAQAECwkIBwUVCgkIC18gBBkWCgAGBQJiSy7WAAoJEOEz2Vo79Yyl\n" +
    "zN0A/iZAVklSJsfQslshR6/zMBufwCK1S05jg/5Ydaksv3QcAQC4gsxdFFne+H4M\n" +
    "mos4atad6hMhlqr0/Zyc71ZdO5I/CAAKCRCs8hbw+T3dIGhqAQCIdVtCus336cDe\n" +
    "Nug+E9v1PEM3F/dt6GAqSG8LJqdAGgEA8cUXdUBooOo/QBkDnpteke8Z3IhIGyGe\n" +
    "dc8OwJyVFwc=\n" +
    "=ARAi\n" +
    "-----END PGP PRIVATE KEY BLOCK-----\n"
    
    static let Test_Public  = "-----BEGIN PGP PUBLIC KEY BLOCK-----\n" +
    "Version: PGPainless\n" +
    "Comment: 12E3 4F04 C66D 2B70 D16C  960D ACF2 16F0 F93D DD20\n" +
    "Comment: alice@pgpainless.org\n" +
    "\n" +
    "mDMEYksu1hYJKwYBBAHaRw8BAQdAIhUpRrs6zFTBI1pK40jCkzY/DQ/t4fUgNtlS\n" +
    "mXOt1cK0FGFsaWNlQHBncGFpbmxlc3Mub3JniI8EExYKAEEFAmJLLtYJEKzyFvD5\n" +
    "Pd0gFiEEEuNPBMZtK3DRbJYNrPIW8Pk93SACngECmwEFFgIDAQAECwkIBwUVCgkI\n" +
    "CwKZAQAA45MBAN9SxFBICzR382bhgiur6BTuA51Mm5/fd/+7+7WcYzV8AP9Fjsje\n" +
    "BChnSVZu9dWREAsK71xQl28vuSlbWhi1iDbVC7g4BGJLLtYSCisGAQQBl1UBBQEB\n" +
    "B0DrQXziToxj9TIEJl7j9Y/wkPD8R+7n8bKTyFx3cfMcWwMBCAeIdQQYFgoAHQUC\n" +
    "Yksu1gKeAQKbDAUWAgMBAAQLCQgHBRUKCQgLAAoJEKzyFvD5Pd0gnegA/2Nyxdkb\n" +
    "4GxGjgbQLx+sNGQT6Kwd65OncfgHtBr1uBPMAPkB5oDaNKXZA8U5dATdSguwVdYk\n" +
    "RanvVaO31tiy34ZRBLgzBGJLLtYWCSsGAQQB2kcPAQEHQD7amqdtf85lc8Th5Pvv\n" +
    "PdfxGUjYpMFpKvbdKZmI4bSfiNUEGBYKAH0FAmJLLtYCngECmwIFFgIDAQAECwkI\n" +
    "BwUVCgkIC18gBBkWCgAGBQJiSy7WAAoJEOEz2Vo79YylzN0A/iZAVklSJsfQslsh\n" +
    "R6/zMBufwCK1S05jg/5Ydaksv3QcAQC4gsxdFFne+H4Mmos4atad6hMhlqr0/Zyc\n" +
    "71ZdO5I/CAAKCRCs8hbw+T3dIGhqAQCIdVtCus336cDeNug+E9v1PEM3F/dt6GAq\n" +
    "SG8LJqdAGgEA8cUXdUBooOo/QBkDnpteke8Z3IhIGyGedc8OwJyVFwc=\n" +
    "=GUhm\n" +
    "-----END PGP PUBLIC KEY BLOCK-----\n"
     */
}

