

import Foundation
import Alamofire
import SwiftyJSON

class ServerManager: NSObject {
    
    static let shared = ServerManager()
    
    typealias Completion = (Bool, JSON, String) -> ()
    
    func getPhotos(page: Int, completion: @escaping Completion) {
        
        let params: Parameters = ["page": page]
        
        Alamofire.request("https://wallpapers.mediacube.games/api/photos", method: .get, parameters: params, encoding: JSONEncoding.default, headers: nil).response { (response) in
            self.responseHandler(response: response, completion: completion)
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> ()) {

        getData(from: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            completion(UIImage(data: data))
        }
    }
    
    func getVideo(urlString: String, completion: @escaping (URL?) -> ()) {
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationFileUrl = documentsUrl.appendingPathComponent("tmp.jpg")
        
        if let fileURL = URL(string: urlString) {
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            
            let request = URLRequest(url:fileURL)
            
            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    
                    completion(tempLocalUrl)
//                    do {
//                        try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
//                        
//                        completion(tempLocalUrl)
//                    } catch {
//                        completion(nil)
//                    }
                    
                } else {
                    completion(nil)
                }
            }
            task.resume()
        }
    }
    
    //MARK: - ResponseHandler
    
    func responseHandler(response: DefaultDataResponse, completion: @escaping Completion) {
        let status = response.response?.statusCode
        let data = response.data
        if let status = status {
            if status >= 200 && status <= 227 {
                if let data = data {
                    let json = JSON(data: data)
                    completion(true, json, "")
                } else {
                    completion(true, [], "")
                }
            } else if status >= 500 {
                
                if let data = data {
                    let json = JSON(data: data)
                    print(json)
                }
                completion(false, "", "Server error")
            } else{
                if let data = data {
                    let json = JSON(data: data) 
                    if let message = json["username"].string {
                        completion(false, json, message)
                    }
                } else {
                    completion(false, [], "Unknown error")
                }
            }
        }
    }
}
