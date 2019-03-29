

import UIKit
import SDWebImage


class ViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties
    
    var pagesCount: Int?
    var currentPage: Int = 1
    
    var photos: [Photo] = [Photo]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppearance()
        
        getPhotos(page: currentPage)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    //MARK: - Get Data
    
    func getPhotos(page: Int) {
        
        ServerManager.shared.getPhotos(page: page) { (success, response, errorString) in
            if success {
                
                self.pagesCount = response["meta"]["last_page"].intValue
                
                for photo in response["data"].arrayValue {
                    self.photos.append(Photo.init(response: photo))
                }
            } else {
                Navigation.openAlert(message: errorString, viewController: self)
            }
        }
    }
    
    //MARK: - Appearance
    
    func setAppearance() {
        
    }
    
    //MARK: - Actions
    

}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell
        
        cell?.imageView.sd_setShowActivityIndicatorView(true)
        cell?.imageView.sd_setIndicatorStyle(.gray)
        cell?.imageView.sd_setImage(with: URL(string: photos[indexPath.row].imagePath), completed: nil)
        
        return cell ?? PhotoCell()
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        activityIndicatorView.startAnimating()
        
        ServerManager.shared.getVideo(urlString: photos[indexPath.row].moviePath) { (url) in
            
            if let url = url, let imageURL = URL.init(string: self.photos[indexPath.row].imagePath) {
                
                ServerManager.shared.downloadImage(from: imageURL, completion: { (image) in
                    
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                    }
                    
                    if let image = image {
                        Navigation.openPhoto(viewController: self, pickedPhoto: image, videoURL: url)
                    } else {
                        Navigation.openAlert(message: "Unknown server error", viewController: self)
                    }
                })
            } else {
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                }
                Navigation.openAlert(message: "Unknown server error", viewController: self)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row == photos.count - 1 {
            
            currentPage += 1
            
            if let pagesCount = pagesCount, currentPage <= pagesCount {
                getPhotos(page: currentPage)
            }
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let side = collectionView.frame.width - 20
        
        return CGSize.init(width: side, height: side)
    }
}

