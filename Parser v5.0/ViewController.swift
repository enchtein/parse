//
//  ViewController.swift
//  Parser v5.0
//
//  Created by enchtein on 30.01.2021.
//

import UIKit
import NVActivityIndicatorView

class ViewController: UIViewController {
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.activeSG = "Start"
            self.clearData = [AllInfo]()
            self.getData(task: .getAllGenres)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.searchBar.isHidden = true
            self.heightSearchBar.constant = 0
            
        case 1:
            self.activeSG = "Search"
            self.clearData = [AllInfo]()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            self.searchBar.isHidden = false
            self.heightSearchBar.constant = 50
            
        case 2:
            self.activeSG = "Favorites"
            self.stepCounter = 2
            self.clearData = [AllInfo]() // вместо массива AllInfo брать массив из кэша
            self.getFavoritesData()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.searchBar.isHidden = true
            self.heightSearchBar.constant = 0
            
            
        default:
            print("default")
        }
    }
    private var activeSG = ""
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var heightSearchBar: NSLayoutConstraint!
    
    @IBAction func backButton(_ sender: UIButton) {
        switch self.stepCounter {
        case 1:
            self.heightBackButton.constant = 0
            self.backButtonOutlet.isHidden = true
            self.getData(task: .getAllGenres)
        case 2:
            self.getData(task: .getAllArtistsByGenre(genre: self.rememberGenre))
            self.rememberGenre = 0
        case 3:
            guard let songData = self.songData else { return }
            self.getData(task: .getAllSongByArtist(artistId: songData.artist!.id))
            self.collectionView.isHidden = true
            self.tableView.isHidden = false
        default:
            print("default")
        }
        self.stepCounter -= 1
    }
    @IBOutlet weak var backButtonOutlet: UIButton!
    @IBOutlet weak var heightBackButton: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var repositoryDataSource = GetData()
    private var clearData = [AllInfo]()
    private var clearDataDelegate: AllInfo?
    private var songData: AllInfo?
    
    private var searchTimer: Timer?
    private var loading: NVActivityIndicatorView?
    
    private var stepCounter = 0
    private var rememberGenre = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.startElementsProperties()
        
        self.tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "cellIdentifier")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 120
        self.collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CustomCollectionViewCell")
        
        
        self.loading = NVActivityIndicatorView(frame: .zero, type: .ballSpinFadeLoader, color: .blue, padding: 0)
        self.loading?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loading!)
        NSLayoutConstraint.activate([
            self.loading!.widthAnchor.constraint(equalToConstant: 40),
            self.loading!.heightAnchor.constraint(equalToConstant: 40),
            self.loading!.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.loading!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])

        self.getData(task: .getAllGenres)
    }
    func startElementsProperties() {
        self.heightSearchBar.constant = 0
        self.searchBar.isHidden = true
        
        self.heightBackButton.constant = 0
        self.backButtonOutlet.isHidden = true
        
        self.collectionView.isHidden = true
    }
    func getData(task: Task) {
        self.loading?.startAnimating()
        GetData.executeTask(with: task) { [weak self] (isSuccess, response) in
            guard let self = self else { return }
            switch task {
            case .getSongData(songId: _):
                self.songData = response.1
                DispatchQueue.main.async {
                    self.loading?.stopAnimating()
                    self.collectionView.reloadData()
                }
            default:
                if isSuccess {
                    self.repositoryDataSource = response.0
                    self.clearData = [AllInfo]()
                    for item in self.repositoryDataSource.data! {
                        self.clearData.append(item)
                    }
                    DispatchQueue.main.async {
                        self.loading?.stopAnimating()
                        self.tableView.reloadData()
                    }
                }
                
            }
        }
    }
    func getFavoritesData() {
      if let storedData = UserDefaults.standard.object(forKey: "favorites") as? Data,
         let favoritesRepo = try? PropertyListDecoder().decode([AllInfo].self, from: storedData) {
        self.clearData = favoritesRepo
      } else {self.clearData.removeAll()}
      self.tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clearData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as? CustomTableViewCell {
            cell.setModel(with: self.clearData[indexPath.row])
            cell.addToFaritesTag.tag = indexPath.row
            cell.addToFaritesTag.addTarget(self, action: #selector(addToFavorites(_:)), for: .touchUpInside)
            cell.deleteFromFavoritesTag.tag = indexPath.row
            cell.deleteFromFavoritesTag.addTarget(self, action: #selector(deleteFromFavorites(_:)), for: .touchUpInside)
            
            cell.delegateCell = self
            
            cell.selectedSegmentControl = self.activeSG
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier") as? CustomTableViewCell {
            self.stepCounter += 1
            self.rewriteModel(cell: self.clearData[indexPath.row])
        }
    }
    @objc func addToFavorites(_ sender: UIButton?) {
//        print(sender!.tag)
        if let index = sender?.tag, self.clearData.indices.contains(index) {
            let alert = UIAlertController(title: "Подтвердите действие", message: "Вы действительно хотите добавить песню?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                print("Yes, I want to add it \(self.clearData[index])")
                // код добавления тут
                self.clearData[index].putObjectToUserDefaults()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                print("NO, I just want to try it! \(self.clearData[index])")
                // можно заменить замыкание на nil
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func deleteFromFavorites(_ sender: UIButton?) {
        if let index = sender?.tag, var storedData = UserDefaults.standard.object(forKey: "favorites") as? Data, storedData.indices.contains(index) {
            print("I can delete it")
            dump(UserDefaults.standard.object(forKey: "favorites") as? Data)
            storedData.remove(at: index)
//            UserDefaults.standard.object(forKey: "favorites")
            print(storedData)
            self.tableView.reloadData()
        }
    }
    
    func rewriteModel(cell: AllInfo?) {
        switch self.stepCounter {
        case 0:
            self.heightBackButton.constant = 0
            self.backButtonOutlet.isHidden = true
        case 1:
            self.heightBackButton.constant = 30
            self.backButtonOutlet.isHidden = false
            self.tableView.isHidden = false
            self.rememberGenre = cell?.id ?? 0
            self.getData(task: .getAllArtistsByGenre(genre: cell?.id ?? 0))
        case 2:
            self.heightBackButton.constant = 30
            self.backButtonOutlet.isHidden = false
            self.tableView.isHidden = false
            self.getData(task: .getAllSongByArtist(artistId: cell?.id ?? self.rememberGenre))
        case 3:
            self.heightBackButton.constant = 30
            self.backButtonOutlet.isHidden = false
            self.tableView.isHidden = true
            self.collectionView.isHidden = false
            self.getData(task: .getSongData(songId: cell?.id ?? 0))
            print("get third level!")
        
        default:
            self.stepCounter = 0
        }
    }
}

extension ViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as? CustomCollectionViewCell {
            cell.setModel(with: self.songData)
            return cell
        }
        return UICollectionViewCell()
    }
}

extension ViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    self.stepCounter = 2
    if searchText.count >= 3 {
      self.searchTimer?.invalidate()
      self.searchTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { [weak self] (_) in
        self?.getData(task: .getSearchResult(searchtext: searchText.lowercased()))
      })
    }
  }
}


extension ViewController: SomeCellProtocol {
    func imageTapped(row: Int) {
        print("From ViewController", row)
        self.clearDataDelegate = self.clearData[row]
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController {
            vc.clearDataDelegate = self.clearDataDelegate
            self.present(vc, animated: true, completion: nil)
        }
    }

}
