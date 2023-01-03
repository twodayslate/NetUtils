import SwiftUI

protocol NewCopyCellProtocol: View, Hashable, Identifiable {
    typealias Shareable = Codable & Hashable
    var shareable: any Shareable { get }
}
