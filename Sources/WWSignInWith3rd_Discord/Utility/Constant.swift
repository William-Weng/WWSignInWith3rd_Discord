//
//  Constant.swift
//  WWSignInWith3rd_Discord
//
//  Created by William.Weng on 2025/3/27.
//

import UIKit
import WWSignInWith3rd_Apple

// MARK: - typealias
public extension WWSignInWith3rd.Discord {
    
    /// 網路回傳的資料 (原始資料, HTTP回應)
    typealias ResponseInformation = (data: Data?, response: HTTPURLResponse?)
}

// MARK: - typealias
extension WWSignInWith3rd.Discord {

    /// 使用API的相關需要的資料
    typealias DiscordApiInformation = (key: String, authorize: String, accessToken: String, revokeToken: String, user: String)
    
    /// 認證Token資訊
    typealias TokenInformation = (type: String, token: String)
}

