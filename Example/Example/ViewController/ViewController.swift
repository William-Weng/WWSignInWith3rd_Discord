//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2025/3/27.
//

import UIKit
import WWSignInWith3rd_Apple
import WWSignInWith3rd_Discord

// MARK: - ViewController
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
