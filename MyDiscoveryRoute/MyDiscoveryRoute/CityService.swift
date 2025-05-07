

import Foundation

class CityService {
    
    static let shared = CityService()
    private init() {}
    
    typealias CityDataCompletion = (Result<CityLocation, Error>) -> Void
    
    private var isLoading = false
    
    func fetchCityData(page: Int, completion: @escaping CityDataCompletion) {
        guard !isLoading else { return }
        isLoading = true
        
        let urlString = "https://storage.googleapis.com/invio-com/usg-challenge/city-location/page-\(page).json"
        guard let url = URL(string: urlString) else {
            isLoading = false
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
                    defer {
                self.isLoading = false
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let cityLocation = try JSONDecoder().decode(CityLocation.self, from: data)
                completion(.success(cityLocation))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Geçersiz URL"
        case .noData:
            return "Veri alınamadı"
        case .decodingError:
            return "Veri işlenirken hata oluştu"
        }
    }
}
