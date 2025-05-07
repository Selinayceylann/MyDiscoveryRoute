

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var cityLabel: UILabel!
    
    var subTableView: UITableView!
    var locations: [Location] = []
    var indexPath: IndexPath?
    var parentVC: HomeViewController?
    
    
     var favoriteLocations: Set<String> = []
     var favoriteToggleHandler: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.isHidden = true
        setupSubTableView()
        

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
  

    @IBAction func detailButtonClicked(_ sender: Any) {
        guard let indexPath = indexPath else { return }
                
        parentVC?.toggleExpandCell(at: indexPath)
    }
    
        func setupSubTableView() {
            subTableView = UITableView(frame: containerView.bounds, style: .plain)
            subTableView.delegate = self
            subTableView.dataSource = self
            subTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
            subTableView.isScrollEnabled = false
            containerView.addSubview(subTableView)
            
            subTableView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                subTableView.topAnchor.constraint(equalTo: containerView.topAnchor),
                subTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                subTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                subTableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        }

            func updateCellState(isExpanded: Bool) {
            containerView.isHidden = !isExpanded
            let buttonTitle = isExpanded ? "Gizle" : "Detay"
            detailButton.setTitle(buttonTitle, for: .normal)
            
            if isExpanded {
                subTableView.reloadData()
            }
        }
}

extension HomeTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
              let location = locations[indexPath.row]
              
              cell.textLabel?.text = location.name
              cell.detailTextLabel?.text = location.description
              
              let favoriteButton = UIButton(type: .custom)
              let isFavorite = favoriteLocations.contains(location.name)
              let heartImage = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
              favoriteButton.setImage(heartImage, for: .normal)
              favoriteButton.tintColor = isFavorite ? .red : .gray
              favoriteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
              favoriteButton.tag = indexPath.row // Tıklanılınca hangi konumun belirlenebilmesi için
              favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
              
              cell.accessoryView = favoriteButton
              
              return cell
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let selectedLocation = locations[indexPath.row]
            
            parentVC?.performSegue(withIdentifier: "toDetailVC", sender: selectedLocation)
        }
    
    @objc func favoriteButtonTapped(_ sender: UIButton) {
          let locationIndex = sender.tag
          if locationIndex < locations.count {
              let locationName = locations[locationIndex].name
              favoriteToggleHandler?(locationName)
              
              subTableView.reloadData()
          }
      }
}
