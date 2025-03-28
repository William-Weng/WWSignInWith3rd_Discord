//
//  Extension.swift
//  WWSignInWith3rd_Discord
//
//  Created by William.Weng on 2025/3/27.
//

import WebKit

// MARK: - WKWebsiteDataStore (function)
extension WKWebsiteDataStore {
    
    /// 清除所有的網路記憶
    /// - Parameters:
    ///   - date: 從這一天以後的
    ///   - completion: (Bool) -> Void)?
    func _clearWebViewMemory(for date: Date = .init(timeIntervalSince1970: 0), completion: ((Bool) -> Void)? = nil) {
        
        let allTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        removeData(ofTypes: allTypes, modifiedSince: date) { completion?(true) }
    }
    
    /// [清除特定的網路記憶 - 登出](https://stackoverflow.com/questions/31289838/how-to-delete-wkwebview-cookies)
    /// - Parameters:
    ///   - key: String
    ///   - completion: (Bool)
    func _clearWebViewMemory(contains key: String, completion: ((Bool) -> Void)? = nil) {
        
        let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
                
        self.fetchDataRecords(ofTypes: websiteDataTypes) { records in
            
            self.removeData(ofTypes: websiteDataTypes, for: records.filter({ record in
                
                
                print(record.displayName)
                
                return record.displayName.contains(key)
            }), completionHandler: {
                completion?(true)
            })
        }
    }
}
