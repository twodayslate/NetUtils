import Foundation
import SwiftUI
import Combine

@available(iOS 15.0, *)
class HostViewModel: ObservableObject {
    @Published var sections: [HostViewSection]
    
    static var hiddenKey = "hostviewmodel.hidden"
    
    @Published var hidden: [String] = UserDefaults.standard.object(forKey: HostViewModel.hiddenKey) as? [String] ?? [] {
        didSet {
            UserDefaults.standard.set(self.hidden, forKey: Self.hiddenKey)
            self.generateVisibleSections()
            objectWillChange.send()
        }
    }
            
    init() {
        self.sections = []
        self.generateVisibleSections()
    }
        
    private func generateVisibleSections() {
        let sections = [
//            HostSectionModel(SimpleDNSResolver.current, service: SimpleDNSResolver.resolver),
//            HostSectionModel(WhoisXml.current, service: WhoisXml.dnsService),
            WhoisXmlWhoisSectionModel(),
//            HostSectionModel(GoogleWebRisk.current, service: GoogleWebRisk.lookupService),
            MonapiSectionModel()]
        let visible_section_titles = sections.drop(while: { self.hidden.contains($0.service.name) })
        
        
        self.sections = visible_section_titles.map {
            return HostViewSection(model: self, sectionModel: $0)
        }
    }
    
    @Published var isQuerying: Bool = false
    
    private var workItems = [DispatchWorkItem]()
    private let _queue = DispatchQueue(label: "HostViewModelQueue")
    
    func query(url: URL? = nil, completion block: (()->())? = nil) {
        self.cancel()
        self.isQuerying = true
        
        let group = DispatchGroup()
    
        for section in self.sections {
            group.enter()
            
            var item: DispatchWorkItem!
            item = DispatchWorkItem {
                section.sectionModel.query(url: url) {
                    group.leave()
                }
            }
            _queue.async {
                item.perform()
            }
        }
        
        group.notify(queue: .main) {
            self.isQuerying = false
            block?()
        }
    }
    
    func cancel() {
        for item in workItems {
            item.cancel()
        }
        workItems.removeAll()
        self.isQuerying = false
    }
}
