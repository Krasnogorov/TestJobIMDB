//
//  NetworkManager.swift
//  TestTaskIMDB
//
//  Created by Sergey Krasnogorov on 11/7/19.
//  Copyright © 2019 Sergey Krasnogorov. All rights reserved.
//

import Foundation

/**
  Class-singleton for making network requests
 */
class NetworkManager
{
    /**
        Instance of manager
     */
    private static let _sharedInstance = NetworkManager();
    /**
        Getter of manager
     */
    public static func SharedInstance() -> NetworkManager
    {
        return _sharedInstance;
    }
    /**
        Make get request to selected url and get callback with response and error
     */
    public func MakeGetRequest(urlPath: String, Callback: @escaping(Data?, String?) -> Void )
    {
        if (!NetworkConnection.isConnectedToNetwork()) {
            Callback(nil, NSLocalizedString("It is no internet connection", comment: ""));
        }
        let url = URL(string: urlPath)!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            Callback(data, error?.localizedDescription);
        }
        task.resume()
    }
}
