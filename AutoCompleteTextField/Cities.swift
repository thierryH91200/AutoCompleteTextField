//
//  Feed.swift
//  Reader
//
//  Created by Jean-Pierre Distler on 19.01.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Cocoa

//{
//    "name" : "Forville",
//    "_id" : 3017680,
//    "coord" : {
//        "lon" : 6.6239,
//        "lat" : 44.913849
//    },
//    "country" : "FR"
//},

public struct Cities2: Codable {
    var cities2: [Cities1]
    
}

public struct Cities1: Codable {
    
    var name: String
    var id : Int
    var country : String
    var coord : Coordinates
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case id = "_id"
        case country = "country"
        case coord = "coord"
    }
}

public struct Coordinates: Codable {
    /// Longitude of the object
    public var longitude: Double
    /// Latitude of the object
    public var latitude: Double
    
    enum CodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }
}
