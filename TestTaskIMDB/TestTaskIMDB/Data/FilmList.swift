//
//  FilmList.swift
//  TestTaskIMDB
//
//  Created by Sergey Krasnogorov on 11/7/19.
//  Copyright © 2019 Sergey Krasnogorov. All rights reserved.
//

import Foundation

struct  FilmList: Decodable {
    enum CodingKeys: String, CodingKey {
        case results
    }
    let items: [Film]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode([Film].self, forKey: .results)
    }
}
