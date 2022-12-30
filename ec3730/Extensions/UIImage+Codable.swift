import UIKit

enum UIImageDecodingError: Error {
    case unableToCreateImage
    case unableToGetImageData
}

public extension Decodable where Self: UIImage {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        if let image = Self(data: data) {
            self = image
        }
        throw UIImageDecodingError.unableToCreateImage
    }
}

public extension Encodable where Self: UIImage {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let data = pngData() {
            try container.encode(data)
        } else if let data = jpegData(compressionQuality: 1.0) {
            try container.encode(data)
        }
        throw UIImageDecodingError.unableToGetImageData
    }
}

extension UIImage: Codable {}
