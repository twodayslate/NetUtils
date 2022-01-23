import SwiftUI

import SwiftUI

import SwiftUI

class GoogleWebRiskSectionModel: HostSectionModel {
    convenience init() {
        self.init(GoogleWebRisk.current, service: GoogleWebRisk.lookupService)
        self.storeModel = StoreKitModel.webrisk
    }

    override func configure(with data: Data) {
        self.content.removeAll()
        self.dataToCopy = nil
        guard let result = try? JSONDecoder().decode(GoogleWebRiskRecordWrapper.self, from: data) else {
            return
        }
        self.configure(with: result)
    }
    
    func configure(with record: GoogleWebRiskRecordWrapper?) {
        DispatchQueue.main.async {
            self.content.removeAll()
            
            if let copyData = try? JSONEncoder().encode(record) {
                self.dataToCopy = String(data: copyData, encoding: .utf8)
            }
            
            if let threats = record?.threat {
                for threat in threats.threatTypes {
                    self.content.append(CopyCellView(title: "Risk", content: threat.description))
                }
            } else {
                self.content.append(CopyCellView(title: "Risk", content: "None detected"))
            }
        }
    }
    
    override func query(url: URL? = nil, completion block: (() -> ())? = nil) {
        self.dataToCopy = nil
        self.content.removeAll()
        
        guard let host = url?.absoluteString else {
            block?()
            return
        }
        
        guard (self.dataFeed.userKey != nil || self.storeModel?.owned ?? false) else {
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


