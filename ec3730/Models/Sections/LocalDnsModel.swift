import SwiftUI

class LocalDnsModel: HostSectionModel {
    convenience init() {
        self.init(LocalDns.current, service: LocalDns.lookupService)
    }

    override func query(url: URL? = nil, completion block: (() -> ())? = nil) {
        guard let host = url?.host else {
            block?()
            return
        }
        
        self.service.query(["host": host]) { (error, response: [String]?) in
            self.content.removeAll()
            guard let addresses = response else {
                return
            }
            for address in addresses {
                self.content.append(CopyCellView(title: "Address", content: address))
            }
        }
    }
}
