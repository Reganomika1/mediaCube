
import Foundation
import SwiftyJSON


struct Photo {
    
    var id: String
    var moviePath: String
    var imagePath: String
    var createdAt: String
    var apdatedAt: String
    
    init(response: JSON) {
        id = response["id"].stringValue
        moviePath = response["movie_path"].stringValue
        imagePath = response["image_path"].stringValue
        createdAt = response["created_at"].stringValue
        apdatedAt = response["updated_at"].stringValue
    }
}
