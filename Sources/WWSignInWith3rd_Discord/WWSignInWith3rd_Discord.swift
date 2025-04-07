//
//  WWSignInWith3rd_Discord.swift
//  WWSignInWith3rd_Discord
//
//  Created by William.Weng on 2025/3/27.
//

import UIKit
import WebKit
import WWNetworking
import WWSignInWith3rd_Apple

// MARK: - [第三方登入](https://discord.com/developers/docs/topics/oauth2)
extension WWSignInWith3rd {
    
    open class Discord: NSObject {
        
        public static let shared = Discord()
                
        private let DiscordURL: DiscordApiInformation = (
            key: "discord.com",
            authorize: "https://discord.com/api/oauth2/authorize",
            accessToken: "https://discord.com/api/oauth2/token",
            revokeToken: "https://discord.com/api/oauth2/token/revoke",
            user: "https://discord.com/api/users/@me"
        )
        
        private(set) var clientId: String?
        private(set) var secret: String?
        private(set) var redirectUri: String?
        private(set) var scope: String?
        
        private var completionBlock: ((Result<Data, Error>) -> Void)?
        private var navigationController = UINavigationController()
        
        private override init() {}
    }
}

// MARK: - 公開函式
public extension WWSignInWith3rd.Discord {
    
    /// [參數設定](https://discord.com/developers/applications)
    /// - Parameters:
    ///   - clientId: [String](https://haer0248.me/blog/145/在網站上使用-discord-登入/)
    ///   - secret: String
    ///   - callbackURL: String
    ///   - scope: String
    func configure(clientId: String, secret: String, redirectUri: String, scope: String = "identify+email") {
        
        self.clientId = clientId
        self.secret = secret
        self.redirectUri = redirectUri
        self.scope = scope
    }
    
    /// [網頁登入](https://discord.com/developers/docs/topics/oauth2)
    /// - Parameters:
    ///   - viewController: [UIViewController](https://stackoverflow.com/questions/79379871/swift-discord-oauth2-redirect-uri-not-supported-by-client)
    ///   - completion: Result<Data, Error>
    func loginWithWeb(presenting viewController: UIViewController, title: String? = "Discord", completion: ((Result<Data, Error>) -> Void)?) {
        
        completionBlock = completion
        
        guard let authorizeUrl = authorizeUrl(clientId: clientId, redirectUri: redirectUri, scope: scope) else { completionBlock?(.failure(WWSignInWith3rd.CustomError.unauthorization)); return }
        
        let navigationController = signInNavigationController(with: authorizeUrl, title: title)
        viewController.present(navigationController, animated: true) {
            navigationController.presentationController?.delegate = self
        }
    }
    
    /// 網頁登出
    /// - Parameter completion: (Bool) -> Void)?
    func logoutWithWeb(completion: ((Bool) -> Void)? = nil) {
        WKWebsiteDataStore.default()._clearWebViewMemory(contains: DiscordURL.key) { completion?($0) }
    }
}

// MARK: - WKNavigationDelegate & WKUIDelegate
extension WWSignInWith3rd.Discord: WKNavigationDelegate, WKUIDelegate {}
public extension WWSignInWith3rd.Discord {
    
     func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping ((WKNavigationResponsePolicy) -> Void)) {
         let policy = signInAction(webView, redirectUri: redirectUri, field: "code", decidePolicyFor: navigationResponse)
         decisionHandler(policy)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension WWSignInWith3rd.Discord: UIAdaptivePresentationControllerDelegate {}
public extension WWSignInWith3rd.Discord {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.completionBlock?(.failure(WWSignInWith3rd.CustomError.isCancel))
    }
}

// MARK: - @objc
private extension WWSignInWith3rd.Discord {
    
    /// [按下取消按鍵的動作](https://www.jianshu.com/p/0adaa6ddd260)
    /// - Parameters:
    ///   - sender: UIBarButtonItem
    ///   - event: UIEvent
    @objc func dismissNavigationController(_ sender: UIBarButtonItem, event: UIEvent) {
        navigationController.dismiss(animated: true) {
            self.completionBlock?(.failure(WWSignInWith3rd.CustomError.isCancel))
        }
    }
}

// MARK: - 小工具
private extension WWSignInWith3rd.Discord {
    
    /// 獲取授權URL => https://discord.com/api/oauth2/authorize?client_id=<client_id>&redirect_uri=<redirect_uri>&response_type=<response_type>&scope=<scope>
    /// - Parameters:
    ///   - clientId: String?
    ///   - redirectUri: String?
    ///   - scope: String?
    ///   - responseType: String
    /// - Returns: URL?
    func authorizeUrl(clientId: String?, redirectUri: String?, scope: String?, responseType: String = "code") -> URL? {
        
        guard let clientId = clientId,
              let redirectUri = redirectUri,
              let scope = scope,
              var components = URLComponents(string: DiscordURL.authorize)
        else {
            return nil
        }
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "response_type", value: responseType),
            URLQueryItem(name: "scope", value: scope)
        ]
        
        return components.url
    }
    
    /// 產生要登入的ViewController
    /// - Parameters:
    ///   - url: URL
    ///   - title: String?
    /// - Returns: UINavigationController
    func signInNavigationController(with url: URL, title: String?) -> UINavigationController {
        
        let rootViewController = UIViewController()
        let itemImage = UIImage(named: "close", in: .module, with: nil)
        let webView = WKWebView._build(delegate: self, frame: .zero, configuration: WKWebViewConfiguration(), contentInsetAdjustmentBehavior: .automatic)
        let cancelItem = UIBarButtonItem(image: itemImage, style: .plain, target: self, action: #selector(dismissNavigationController(_:event:)))
        
        _ = webView._load(urlString: url.absoluteString, timeoutInterval: .infinity)
        
        rootViewController.view = webView
        rootViewController.navigationItem.title = title
        rootViewController.navigationItem.setRightBarButton(cancelItem, animated: true)
        
        navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.view.tintColor = .red
        
        return navigationController
    }
    
    /// [第三方登入的過程 - OAuth 2.0](https://www.ruanyifeng.com/blog/2014/05/oauth_2_0.html)
    /// - Parameters:
    ///   - webView: WKWebView
    ///   - navigationResponse: WKNavigationResponse
    func signInAction(_ webView: WKWebView, redirectUri: String?, field: String, decidePolicyFor navigationResponse: WKNavigationResponse) -> WKNavigationResponsePolicy {
        
        guard let url = navigationResponse.response.url,
              let redirectUri = redirectUri,
              url.absoluteString.hasPrefix(redirectUri)
        else {
            return .allow
        }
        
        guard let clientId = self.clientId,
              let clientSecret = self.secret,
              let queryItems = URLComponents(string: url.absoluteString)?.queryItems,
              let code = queryItems.first(where: { item in return item.name == field })?.value
        else {
            navigationController.dismiss(animated: true) { self.completionBlock?(.failure(WWSignInWith3rd.CustomError.isCancel)) }
            return .cancel
        }
        
        let urlString = DiscordURL.accessToken
        let grantType = "authorization_code"
        let items = ["client_id": clientId, "client_secret": clientSecret, "code": code, "grant_type": grantType, "redirect_uri": redirectUri]
                
        authorizeAction(urlString: DiscordURL.accessToken, items: items)
        return .cancel
    }
    
    /// OAuth 2.0認證過程 => client_secret=<client_secret>&code=<code>&client_id=<client_id>&redirect_uri=<redirect_uri>&grant_type=<grant_type>
    /// - Parameters:
    ///   - urlString: String
    ///   - items: [String: String]
    func authorizeAction(urlString: String, items: [String: String]) {
        
        WWNetworking.shared.request(httpMethod: .POST, urlString: urlString, contentType: .formUrlEncoded, httpBodyType: .form(items)) { result in
            
            switch result {
            case .failure(let error): self.completionBlock?(.failure(error))
            case .success(let info):
                
                guard let response = info.response else { self.completionBlock?(.failure(WWSignInWith3rd.CustomError.notResponse(urlString))) ;return }
                
                switch response.statusCode {
                case 200:
                                        
                    let accessTokenResult = self.accessToken(with: info)

                    switch accessTokenResult {
                    case .failure(let error): self.completionBlock?(.failure(error))
                    case .success(let type, let token):
                        
                        let headers = ["\(WWNetworking.HTTPHeaderField.authorization)": "\(type) \(token)"]
                        
                        WWNetworking.shared.request(httpMethod: .GET, urlString: self.DiscordURL.user, contentType: .formUrlEncoded, headers: headers) { _result in
                            
                            switch _result {
                            case .failure(let error): self.completionBlock?(.failure(error))
                            case .success(let info):
                                
                                guard let data = info.data else { self.completionBlock?(.failure(WWSignInWith3rd.CustomError.isEmpty)); return }
                                
                                self.completionBlock?(.success(data))
                                DispatchQueue.main.async { self.navigationController.dismiss(animated: true) {}}
                            }
                        }
                    }
                    
                default: self.completionBlock?(.failure(WWSignInWith3rd.CustomError.httpError(response.statusCode, data: info.data)))
                }
            }
        }
    }
    
    /// 解析回傳回來的資訊 => 取得(TokenType, AccessToken)
    /// - Parameter info: Constant.ResponseInformation
    /// - Returns: String
    func accessToken(with info: ResponseInformation) -> Result<(String, String), Error> {
                
        guard let jsonObject = info.data?._jsonObject() as? [String: Any],
              let accessToken = jsonObject["access_token"] as? String,
              let tokenType = jsonObject["token_type"] as? String
        else {
            return .failure(WWSignInWith3rd.CustomError.otherError("accessToken is null."))
        }
        
        return .success((tokenType, accessToken))
    }
}
