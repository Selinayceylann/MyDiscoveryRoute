

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var homeTableView: UITableView!
    
    var cityData: [Datum] = []
    
    var currentPage = 1
    var totalPages = 1
    var isLoading = false
    
    var expandedCells = Set<Int>()
    
    var favoriteLocations = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Önemli Konumlar"
        
        let favoritesButton = UIBarButtonItem(image: UIImage(systemName: "heart.fill"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(openFavorites))
        navigationItem.rightBarButtonItem = favoritesButton
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        let collapseButton = UIButton(type: .system)
        collapseButton.setTitle("Tümünü Kapat", for: .normal)
        collapseButton.backgroundColor = UIColor.systemBlue
        collapseButton.setTitleColor(UIColor.white, for: .normal)
        collapseButton.layer.cornerRadius = 8
        collapseButton.addTarget(self, action: #selector(collapseAllCells), for: .touchUpInside)
        collapseButton.translatesAutoresizingMaskIntoConstraints = false
        
        footerView.addSubview(collapseButton)
        
        NSLayoutConstraint.activate([
            collapseButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),
            collapseButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -10),
            collapseButton.widthAnchor.constraint(equalToConstant: 120),
            collapseButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        homeTableView.tableFooterView = footerView
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        homeTableView.estimatedRowHeight = 60
        homeTableView.rowHeight = UITableView.automaticDimension
        
        loadFavorites()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        homeTableView.refreshControl = refreshControl
        

        homeTableView.reloadData()
    }

    
    @objc func openFavorites() {
        performSegue(withIdentifier: "toFavoritesVC", sender: nil)
    }
    
    @objc func refreshData() {
        currentPage = 1
        cityData.removeAll()
        expandedCells.removeAll()
        fetchCityData(page: currentPage)
    }
    
    @objc func collapseAllCells() {
        expandedCells.removeAll()
        homeTableView.reloadData()
    }
    
    
    func loadFavorites() {
        if let savedFavorites = UserDefaults.standard.array(forKey: "FavoriteLocations") as? [String] {
            favoriteLocations = Set(savedFavorites)
        }
    }
    
    func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteLocations), forKey: "FavoriteLocations")
    }
    
    func toggleFavorite(locationName: String) {
        if favoriteLocations.contains(locationName) {
            favoriteLocations.remove(locationName)
        } else {
            favoriteLocations.insert(locationName)
        }
        saveFavorites()
        homeTableView.reloadData()
    }
    
    func fetchCityData(page: Int) {
            guard !isLoading else { return }
            isLoading = true
            
            CityService.shared.fetchCityData(page: page) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.homeTableView.refreshControl?.endRefreshing()
                    
                    switch result {
                    case .success(let cityLocation):
                        if self.currentPage == 1 {
                            self.cityData = cityLocation.data
                        } else {
                            self.cityData.append(contentsOf: cityLocation.data)
                        }
                        
                        self.totalPages = cityLocation.totalPage
                        self.homeTableView.reloadData()
                        
                    case .failure(let error):
                        print("Error fetching data: \(error.localizedDescription)")
                        self.showErrorAlert(message: error.localizedDescription)
                    }
                }
            }
        }
    
    func showErrorAlert(message: String) {
            let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
        }
    
    func loadMoreData() {
        if currentPage < totalPages {
            currentPage += 1
            fetchCityData(page: currentPage)
        }
    }
    
    func openCityMap(forCityAt indexPath: IndexPath) {
        let city = cityData[indexPath.row]
        
        performSegue(withIdentifier: "toCityMapVC", sender: city)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC", let location = sender as? Location {
            if let detailVC = segue.destination as? DetailViewController {
                detailVC.location = location
                detailVC.isFavorite = favoriteLocations.contains(location.name)
            }
        } else if segue.identifier == "toFavoritesVC" {
            if let favoritesVC = segue.destination as? FavoritesViewController {
                // Tüm şehir ve konum verilerini ve favori listesini gönder
                var allLocations: [Location] = []
                for city in cityData {
                    allLocations.append(contentsOf: city.locations)
                }
                
                let favorites = allLocations.filter { favoriteLocations.contains($0.name) }
                favoritesVC.favoriteLocations = favorites
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = homeTableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as! HomeTableViewCell
        
        let cityInfo = cityData[indexPath.row]
        cell.cityLabel.text = cityInfo.city
        cell.locations = cityInfo.locations
        cell.indexPath = indexPath
        cell.parentVC = self
        cell.favoriteLocations = favoriteLocations
        cell.favoriteToggleHandler = { [weak self] locationName in
            self?.toggleFavorite(locationName: locationName)
        }
        
        if cityInfo.locations.isEmpty {
            cell.detailButton.isHidden = true
        } else {
            cell.detailButton.isHidden = false
        }
        
        let isExpanded = expandedCells.contains(indexPath.row)
        cell.updateCellState(isExpanded: isExpanded)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let baseHeight: CGFloat = 60
        
        if expandedCells.contains(indexPath.row) {
            let locationCount = cityData[indexPath.row].locations.count
            let subTableHeight = CGFloat(locationCount) * 44
            return baseHeight + subTableHeight
        }
        
        return baseHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItemIndex = cityData.count - 1
        if indexPath.row == lastItemIndex - 3 && !isLoading {
            loadMoreData()
        }
    }
    
    func toggleExpandCell(at indexPath: IndexPath) {
        if expandedCells.contains(indexPath.row) {
            expandedCells.remove(indexPath.row)
        } else {
            expandedCells.insert(indexPath.row)
        }
        
        homeTableView.beginUpdates()
        homeTableView.endUpdates()
        
        if let cell = homeTableView.cellForRow(at: indexPath) as? HomeTableViewCell {
            let isExpanded = expandedCells.contains(indexPath.row)
            cell.updateCellState(isExpanded: isExpanded)
        }
    }
}
