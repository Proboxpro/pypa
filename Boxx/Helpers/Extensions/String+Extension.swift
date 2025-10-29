//
//  String+Extension.swift
//  Boxx
//
//  Created by Nikita Evdokimov on 12.04.24.
//

import Foundation
import CommonCrypto

extension String {
    func toDate() -> Date? {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "dd.MM.yyyy в HH:mm"
        
        return inputDateFormatter.date(from: self)
    }
    
    func convertToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .current
        
        return dateFormatter.date(from: self)
    }
    
    func convertToDisplayFormat() -> String {
        guard let date = self.convertToDate() else { return "N/A" }
        return date.convertToMonthYearFormat()
    }
    
    var trim: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isEmpty: Bool {
        return trim.lengthOfBytes(using: .utf8) <= 0
    }

    var domain: String? {
        
        return URL(string: self)?.host
    }
    
    var urlQueryEncoded: String {
        
        return addingPercentEncoding(withAllowedCharacters: .percentEncondingSet) ?? self
    }
    
    func hmac256(key: String) -> String {
        
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, self, self.count, &digest)
        
        return Data(digest).map({ String(format: "%02hhx", $0) }).joined()
    }
    
    static func random(len: Int) -> String {
        
        let chars = "abcdefghjklmnpqrstuvwxyz12345789"
        let random = (0..<len).compactMap { _ in chars.randomElement() }
        
        return String(random)
    }
}

extension CharacterSet {
    
    fileprivate static var percentEncondingSet: CharacterSet = {
        
        var set = CharacterSet.urlQueryAllowed
        set.remove(charactersIn: "/+")
        return set
    }()
}
