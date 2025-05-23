# WWSignInWith3rd+Discord

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/) [![iOS-15.0](https://img.shields.io/badge/iOS-15.0-pink.svg?style=flat)](https://developer.apple.com/swift/) ![TAG](https://img.shields.io/github/v/tag/William-Weng/WWSignInWith3rd_Discord) [![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/) [![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

### [Introduction - 簡介](https://swiftpackageindex.com/William-Weng)
- [Use Discord third-party login.](https://discord.com/developers/applications)
- [使用Discord第三方登入。](https://haer0248.me/blog/145/在網站上使用-discord-登入/)

![](./Example.webp)

### [Installation with Swift Package Manager](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-spm-安裝第三方套件-xcode-11-新功能-2c4ffcf85b4b)
```bash
dependencies: [
    .package(url: "https://github.com/William-Weng/WWSignInWith3rd_Discord.git", .upToNextMajor(from: "1.0.1"))
]
```

### [Function](https://discord.com/developers/docs/topics/oauth2)
|函式|功能|
|-|-|
|configure(clientId:secret:redirectUri:scope:)|參數設定|
|loginWithWeb(presenting:title:completion:)|網頁登入|
|logoutWithWeb(completion:)|網頁登出|

### [Example](https://ezgif.com/video-to-webp)
```swift
import UIKit
import WWSignInWith3rd_Apple
import WWSignInWith3rd_Discord

final class ViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    
    private let clientId = "<client_id>"
    private let secret = "<client_secret>"
    private let redirectUri = "<redirect_uri>"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WWSignInWith3rd.Discord.shared.configure(clientId: clientId, secret: secret, redirectUri: redirectUri)
    }
    
    @IBAction func loginWithWeb(_ sender: UIButton) {
        
        WWSignInWith3rd.Discord.shared.loginWithWeb(presenting: self, title: "Discord") { result in
            
            switch result {
            case .failure(let error):
                
                if let customError = error as? WWSignInWith3rd.CustomError {
                    switch customError {
                    case .httpError(let code, _): print("error code = \(code)")
                    default: print(customError)
                    }
                }
                
            case .success(let data):
                guard let dict = data._jsonObject() as? [String: Any] else { return }
                DispatchQueue.main.async { self.emailLabel.text = dict["email"] as? String }
            }
        }
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        WWSignInWith3rd.Discord.shared.logoutWithWeb()
    }
}
```
