import SwiftUI

import SwiftUI

import SwiftUI

class GoogleWebRiskSectionModel: HostSectionModel {
    convenience init() {
        self.init(GoogleWebRisk.current, service: GoogleWebRisk.lookupService)
        self.storeModel = StoreKitModel.webrisk
    }

    func configure(with record: GoogleWebRiskRecordWrapper?) {
        DispatchQueue.main.async {
            self.content.removeAll()
            
            if let copyData = try? JSONEncoder().encode(record) {
                self.dataToCopy = String(data: copyData, encoding: .utf8)
            }
        }
    }
    
    override func query(url: URL? = nil, completion block: (() -> ())? = nil) {
        guard let host = url?.absoluteString else {
            block?()
            return
        }
        
        GoogleWebRisk.lookupService.query(["uri": host]) { (error, response: GoogleWebRiskRecordWrapper?) in
            print(response.debugDescription)

                defer {
                    block?()
                }
                
                guard error == nil else {
                    // todo show error
                    return
                }

                guard let response = response else {
                    // todo show error
                    return
                }

            
                
            self.configure(with: response)
        }
    }
}


