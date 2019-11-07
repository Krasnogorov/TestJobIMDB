//
//  Film.swift
//  TestTaskIMDB
//
//  Created by Sergey Krasnogorov on 11/7/19.
//  Copyright © 2019 Sergey Krasnogorov. All rights reserved.
//

import Foundation


struct Film: Codable {
    var id : Int;
    var title : String;
    var poster : String;
    var description : String;

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case poster_path
    case overview
  }
    
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(title, forKey: .title)
    try container.encode(poster, forKey: .poster_path)
    try container.encode(description, forKey: .overview)
  }
    
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(Int.self, forKey: .id)
    title = try container.decode(String.self, forKey: .title)
    poster = try container.decode(String.self, forKey: .poster_path)
    description = try container.decode(String.self, forKey: .overview)
  }
}
