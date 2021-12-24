//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import CryptoKit
import Foundation

extension Data {
    func urlSafeBase64EncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

struct Header: Encodable {
    let alg = "HS256"
    let typ = "JWT"
}

struct JWTPayload: Encodable {
    let user_id: String
    let exp: Int
}

func genToken(secret: String, userID: String, validFor seconds: Int = 60) -> String {
    let exp = Int(Date().timeIntervalSince1970) + seconds
    
    let privateKey = SymmetricKey(data: secret.data(using: .utf8)!)

    let headerJSONData = try! JSONEncoder().encode(Header())
    let headerBase64String = headerJSONData.urlSafeBase64EncodedString()

    let payloadJSONData = try! JSONEncoder().encode(JWTPayload(user_id: userID, exp: exp))
    let payloadBase64String = payloadJSONData.urlSafeBase64EncodedString()

    let toSign = (headerBase64String + "." + payloadBase64String).data(using: .utf8)!
    let signature = HMAC<SHA256>.authenticationCode(for: toSign, using: privateKey)
    let signatureBase64String = Data(signature).urlSafeBase64EncodedString()

    return [headerBase64String, payloadBase64String, signatureBase64String].joined(separator: ".")
}
