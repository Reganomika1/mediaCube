
import UIKit

class Navigation {
    
    static func openPhoto(viewController: UIViewController, pickedPhoto: UIImage, videoURL: URL) {
        
        if let vc = UIStoryboard.init(name: "LivePhoto", bundle: nil).instantiateInitialViewController() as? LivePhotoController {
            
            vc.pickedPhoto = pickedPhoto
            vc.videoURL = videoURL
            
            DispatchQueue.main.async {
                viewController.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    static func openAlert(title: String?=nil, message: String, viewController: UIViewController) {
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
}
