
import SDWebImage
import UIKit
import Photos
import PhotosUI
import MobileCoreServices
import AVFoundation
import AVKit

class LivePhotoController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var progressView: UIProgressView!
    
    //MARK: - Properties
    
    var photoView: PHLivePhotoView!
    
    var livePhotoResources: LivePhoto.LivePhotoResources?
    var photo: Photo?
    var videoURL: URL?
    var pickedPhoto: UIImage?
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppearance()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //MARK: - Appearance
    
    func setAppearance() {
        
        setNavigationBar()
        setLifePhoto()
    }
    
    func setLifePhoto() {
        
        photoView = PHLivePhotoView.init(frame: self.view.frame)
        photoView.contentMode = .scaleAspectFill
        photoView.backgroundColor = UIColor.gray
        
        self.view.addSubview(photoView)
        self.view.sendSubviewToBack(photoView)
        
        guard let sourceVideoPath = self.videoURL else {
            return
        }
        
        var photoURL: URL?
        
        if let sourceKeyPhoto = self.pickedPhoto {
            guard let data = sourceKeyPhoto.jpegData(compressionQuality: 1.0) else { return }
            photoURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("photo.jpg")
            if let photoURL = photoURL {
                try? data.write(to: photoURL)
            }
        }
        LivePhoto.generate(from: photoURL, videoURL: sourceVideoPath, progress: { (percent) in
            DispatchQueue.main.async {
                self.progressView.progress = Float(percent)
            }
        }) { (livePhoto, resources) in
            self.photoView.livePhoto = livePhoto
            self.livePhotoResources = resources
            
        }
    }
    
    func setNavigationBar() {
        
        let rightBarButtonItem = UIBarButtonItem.init(title: "Share", style: .plain, target: self, action: #selector(shareAction))
        
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    //MARK: - Selectors
    
    @objc func shareAction() {
        
        if let resources = livePhotoResources {
            LivePhoto.saveToLibrary(resources, completion: { (success) in
                if success {
                    Navigation.openAlert(message: "Live Photo succesfully saved", viewController: self)
                } else {
                    Navigation.openAlert(message: "Live Photo saving error", viewController: self)
                }
            })
        }
    }
    
}
