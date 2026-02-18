import NetUtils

extension Interface: @retroactive Identifiable {
    public var id: Int {
        "\(name)\(address ?? "")\(debugDescription)".hashValue
    }
}
