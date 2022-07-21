import NetUtils

extension Interface: Identifiable {
    public var id: Int {
        "\(name)\(address ?? "")\(debugDescription)".hashValue
    }
}
