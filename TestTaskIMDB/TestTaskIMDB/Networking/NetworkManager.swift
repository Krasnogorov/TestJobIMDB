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
    public static let BASE_WEB_ADDRESS : String = "https://api.themoviedb.org/3/discover/movie?api_key=479155cdc996e85e410ccdcf46568480&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=true&page="
    public static let IMAGE_WEB_ADDRESS : String = "https://image.tmdb.org/t/p/w500"
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
            Callback(nil, NSLocalizedString("It is no internet connection.", comment: ""));
        }
        let url = URL(string: urlPath)!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            Callback(data, error?.localizedDescription);
        }
        task.resume()
    }
}
