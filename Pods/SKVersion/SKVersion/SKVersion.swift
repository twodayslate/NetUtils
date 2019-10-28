//
//  VersionUpdate.swift
//  VersionUpdate
//
//  Created by Zachary Gorak on 9/11/19.
//  Copyright © 2019 Zac Gorak. All rights reserved.
//

import Foundation
import Version

extension Bundle {
    /// The App Store Version object of the bundle.
    public var storeVersion: SKVersion? {
        guard let bundleId = self.bundleIdentifier else {
            return nil
        }
        return SKVersion(bundleId, version: self.shortVersion)
    }
}

/// App Store Version object
///
/// Used for checking for an bundle's App Store version and potential updates
/// - SeeAlso: [Check if my app has a new version on AppStore on StackOverflow](https://stackoverflow.com/questions/6256748/check-if-my-app-has-a-new-version-on-appstore)
open class SKVersion {
    // MARK: - Properties
    // MARK: Open
    /// URL used to check for new version results
    open var endpoint: URL? {
        return URL(string: "http://itunes.apple.com/lookup?bundleId=\(self.bundleIdentifier)")
    }
    
    // MARK: Public
    
    /// Bundle Identifier
    public let bundleIdentifier: String
    /// The current version
    public var current: Version

    /// The latest version live on the App Store
    public var latest: Version? {
        get {
            if _latestVersion == nil {
                self.update()
            }
            return _latestVersion
        }
    }
    
    /// Session used for creating the data task
    public var session = URLSession.shared
    
    // MARK: Static/Class
    
    /// Returns the App Store Version object of the current executable.
    public static var main: SKVersion? {
        return Bundle.main.storeVersion
    }
    
    // MARK: Private
    
    /// version to compare against
    private var _latestVersion: Version? = nil
    
    // MARK: - Initializers
    
    /// Returns the SKVersion instance that has the specified bundle identifier.
    ///
    /// If the `version` is not specified in the initializer and cannot be found with the given bundle identifier then it will default to 0.0.
    /// - parameters:
    ///     - identifier: The identifier for an existing NSBundle instance.
    ///     - version: The initial or current version
    public init(_ identifier: String, version: Version? = nil) {
        self.bundleIdentifier = identifier
        self.current = version ?? Bundle(identifier: identifier)?.shortVersion ?? Version("0.0")
    }
    
    // MARK: - Usage
    
    /// Checks if there is an App Store update
    /// - parameters:
    ///     - block: callback
    ///     - canUpdate: Whether or not an update is available on the App Store
    ///     - version: App Store Version available
    ///     - error: Any potential errors
    open func update(completion block: ((_ canUpdate: Bool, _ version: Version?, _ error: Error?)->Void)? = nil) {
        guard let checkUrl = self.endpoint else {
            block?(false, nil, URLError(.badURL))
            return
        }
        
        self.session.dataTask(with: checkUrl) { (data, response, error) in
            guard error == nil else {
                block?(false, nil, error)
                return
            }
            
            do {
                
                guard let reponseJson = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any],
                    let result = (reponseJson["results"] as? [Any])?.first as? [String: Any],
                    let versionString = result["version"] as? String
                    else{
                        block?(false, nil, URLError(.badServerResponse))
                        return
                }
                
                self._latestVersion = try VersionParser(strict: false).parse(string: versionString)
                
                block?(self.current < self.latest!, self.latest!, nil)
                return
            } catch {
                block?(false, nil, error)
                return
            }
        }.resume()
    }
}
