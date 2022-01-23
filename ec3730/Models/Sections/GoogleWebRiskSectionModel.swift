import SwiftUI

import SwiftUI

import SwiftUI

class GoogleWebRiskSectionModel: HostSectionModel {
    convenience init() {
        self.init(GoogleWebRisk.current, service: GoogleWebRisk.lookupService)
        self.storeModel = StoreKitModel.webrisk
    }

    @MainActor
    override func configure(with data: Data) throws -> Data? {
        self.reset()
        
        let result = try JSONDecoder().decode(GoogleWebRiskRecordWrapper.self, from: data)
        return try self.configure(with: result)
    }
    
    @MainActor
    func configure(with record: GoogleWebRiskRecordWrapper) throws -> Data {
        self.reset()
        
        let copyData = try JSONEncoder().encode(record)
        self.latestData = copyData
        self.dataToCopy = String(data: copyData, encoding: .utf8)
        
        
        if let threats = record.threat {
            for threat in threats.threatTypes {
                self.content.append(CopyCellView(title: "Risk", content: threat.description))
            }
        } else {
            self.content.append(CopyCellView(title: "Risk", content: "None detected"))
        }
        return copyData
    }
    
    @MainActor
    override func query(url: URL? = nil, completion block: ((Error?, Data?) -> ())? = nil) {
        self.reset()
        
        guard let host = url?.absoluteString else {
            block?(URLError(.badURL), nil)
            return
        }
        
        guard (self.dataFeed.userKey != nil || self.storeModel?.owned ?? false) else {
            block?(MoreStoreKitError.NotPurchased, nil)
            return
        }

        GoogleWebRisk.lookupService.query(["uri": host]) { (responseError, response: GoogleWebRiskRecordWrapper?) in
            DispatchQueue.main.async {
                print(response.debugDescription)
                    
                guard responseError == nil else {
                    // todo show error
                    block?(responseError, nil)
                    return
                }

                guard let response = response else {
                    // todo show error
                    block?(URLError(.badServerResponse), nil)
                    return
                }
                    
                do {
                    try block?(nil, self.configure(with: response))
                } catch {
                    block?(error, nil)
                }
            }
        }
    }
}


