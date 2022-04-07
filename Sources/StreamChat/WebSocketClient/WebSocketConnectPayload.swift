//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation

struct WebsocketAuthorizedPayload: Encodable {

    enum CodingKeys: String, CodingKey {
        case streamAuthType = "stream-auth-type"
        case token = "authorization"
    }
    let streamAuthType = "jwt"
    let token: String?

    init(token: String?) {
        self.token = token
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Self.CodingKeys)
        try container.encode(streamAuthType, forKey: .streamAuthType)
        try container.encodeIfPresent(token, forKey: .token)
    }
}

class WebSocketConnectPayload: Encodable {
    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userDetails = "user_details"
    }
    
    let userId: UserId
    let userDetails: UserWebSocketPayload

    init(userInfo: UserInfo) {
        userId = userInfo.id
        userDetails = UserWebSocketPayload(userInfo: userInfo)
    }
}

struct UserWebSocketPayload: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case name
        case imageURL = "image"
    }

    let id: String
    let name: String?
    let imageURL: URL?
    let extraData: [String: RawJSON]

    init(userInfo: UserInfo) {
        id = userInfo.id
        name = userInfo.name
        imageURL = userInfo.imageURL
        extraData = userInfo.extraData
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Self.CodingKeys)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try extraData.encode(to: encoder)
    }
}
