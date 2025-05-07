

import UIKit

class DetailViewController: UIViewController {

   
    @IBOutlet weak var showOnMapButton: UIButton!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var location: Location?
    var isFavorite: Bool = false
      
    override func viewDidLoad() {
        super.viewDidLoad()

                navigationItem.leftBarButtonItem = UIBarButtonItem(
                    image: UIImage(systemName: "chevron.left"),
                    style: .plain,
                    target: self,
                    action: #selector(backButtonTapped)
                )
        
                setupUI()
                checkIfFavorite()

    }
    
    func setupUI() {
            guard let location = location else { return }
            
            title = location.name
            nameLabel.text = location.name
            
            descriptionTextView.text = location.description
            
            if let imageUrlString = location.image, let imageUrl = URL(string: imageUrlString) {
                loadImage(from: imageUrl)
            } else {
                locationImageView.image = UIImage(named: "placeholder_image")
            }
            
            showOnMapButton.layer.cornerRadius = 8
            showOnMapButton.backgroundColor = .systemBlue
            showOnMapButton.setTitle("Haritada Göster", for: .normal)
            showOnMapButton.setTitleColor(.white, for: .normal)
        }
    
    func loadImage(from url: URL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async {
                    self?.locationImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    
    func checkIfFavorite() {
            guard let locationId = location?.id else { return }
            
            let favorites = UserDefaults.standard.array(forKey: "FavoriteLocations") as? [Int] ?? []
            isFavorite = favorites.contains(locationId)
        }
    
    
    @objc func backButtonTapped() {
            navigationController?.popViewController(animated: true)
        }
    
    
    @IBAction func showOnMapButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toMapVC" {
                if let mapVC = segue.destination as? MapViewController {
                    mapVC.location = self.location
                    mapVC.title = self.location?.name
                }
            }
        }
}
