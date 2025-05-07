
import UIKit

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var favoritesTableView: UITableView!
    
    var favoriteLocations: [Location] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Favorilerim"
               
               favoritesTableView.delegate = self
               favoritesTableView.dataSource = self
               
               navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Geri",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(dismissVC))
    }
    
    @objc func dismissVC() {
            navigationController?.popViewController(animated: true)
        }
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return favoriteLocations.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath)
            
            let location = favoriteLocations[indexPath.row]
            cell.textLabel?.text = location.name
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let location = favoriteLocations[indexPath.row]
            performSegue(withIdentifier: "toDetailFromFavorites", sender: location)
        }
                
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toDetailFromFavorites", let location = sender as? Location {
                if let detailVC = segue.destination as? DetailViewController {
                    detailVC.location = location
                    detailVC.isFavorite = true // Favoriler sayfasından geldiği için zaten favori
                }
            }
        }
    

}
