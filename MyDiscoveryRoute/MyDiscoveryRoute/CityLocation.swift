

import Foundation

struct CityLocation: Codable {
    let currentPage, totalPage, total, itemPerPage: Int
    let pageSize: Int
    let data: [Datum]
}

struct Datum: Codable {
    let city: String
    let locations: [Location]
}

struct Location: Codable {
    let name, description: String
    let coordinates: Coordinates
    let image: String?
    let id: Int
}

struct Coordinates: Codable {
    let lat, lng: Double
}
