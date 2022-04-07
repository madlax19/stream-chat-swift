//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation

extension Endpoint {
    static func webSocketConnect(
        userInfo: UserInfo,
        token: Token?
    ) -> Endpoint<EmptyResponse> {
        .init(
            path: .connect,
            method: .get,
            queryItems: WebsocketAuthorizedPayload(token: token?.rawValue),
            requiresConnectionId: false,
            body: [
                "json": WebSocketConnectPayload(userInfo: userInfo)
            ]
        )
    }
}
