//
//  ViewController.swift
//  MyDiscoveryRoute
//
//  Created by selinay ceylan on 8.04.2025.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

        var cityData: [Datum] = []
        var totalPages = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

                activityIndicator.startAnimating()
                textLabel.text = "Veriler yükleniyor..."
                
         
                fetchCityData(page: 1)
        
    }
    
    func fetchCityData(page: Int) {
        print("Veri çekme başladı: Sayfa \(page)")
        let urlString = "https://storage.googleapis.com/invio-com/usg-challenge/city-location/page-\(page).json"
        guard let url = URL(string: urlString) else {
            print("URL oluşturulamadı")
            showError(message: "Geçersiz URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else {
                print("Self referansı kayboldu")
                return
            }
            
            if let error = error {
                print("Ağ hatası: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showError(message: "Veri çekilemedi: \(error.localizedDescription)")
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP yanıt kodu: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("Veri alınamadı")
                DispatchQueue.main.async {
                    self.showError(message: "Veri alınamadı")
                }
                return
            }
            
            print("Veri alındı, boyut: \(data.count) bytes")
            
            do {
                let cityLocation = try JSONDecoder().decode(CityLocation.self, from: data)
                print("JSON çözümleme başarılı: \(cityLocation.data.count) şehir alındı")
                
                self.cityData = cityLocation.data
                self.totalPages = cityLocation.totalPage
                
                DispatchQueue.main.async {
                    print("Ana sayfaya yönlendirme başladı")
                    self.navigateToHome()
                }
            } catch {
                print("JSON çözümleme hatası: \(error)")
                DispatchQueue.main.async {
                    self.showError(message: "Veri çözümlenemedi: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        print("Ağ isteği başlatıldı")
    }
    
    func showError(message: String) {
            activityIndicator.stopAnimating()
            textLabel.text = "Hata: \(message)"
            
         
            let retryButton = UIButton(type: .system)
            retryButton.setTitle("Tekrar Dene", for: .normal)
            retryButton.addTarget(self, action: #selector(retryFetch), for: .touchUpInside)
            retryButton.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(retryButton)
            
            NSLayoutConstraint.activate([
                retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                retryButton.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 20)
            ])
        }
    
    @objc func retryFetch() {
    
            for subview in view.subviews {
                if let button = subview as? UIButton {
                    button.removeFromSuperview()
                }
            }
            
            activityIndicator.startAnimating()
            textLabel.text = "Veriler yükleniyor..."
            fetchCityData(page: 1)
        }
    
    func navigateToHome() {
        DispatchQueue.main.async {
            print("navigateToHome fonksiyonu çağrıldı")
          
            self.performSegue(withIdentifier: "toHomeVC", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for segue çağrıldı: \(String(describing: segue.identifier))")
        if segue.identifier == "toHomeVC" {
            if let homeVC = segue.destination as? HomeViewController {
          
                print("HomeViewController'a veriler aktarılıyor")
                homeVC.cityData = self.cityData
                homeVC.totalPages = self.totalPages
                homeVC.currentPage = 1
            } else {
                print("segue.destination HomeViewController olarak cast edilemedi")
            }
        }
    }

  
    
}

