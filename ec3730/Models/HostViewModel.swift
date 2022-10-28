import Combine
import Foundation
import SwiftUI

actor ActorArray<T> {
    var values: [T] = []
    func append(_ values: [T]) {
        self.values.append(contentsOf: values)
    }
}

@available(iOS 15.0, *)
@MainActor
class HostViewModel: ObservableObject {
    @Published var sections: [HostViewSection] {
        didSet {
            order = sections.map(\.sectionModel.service.name)
        }
    }

    static var hiddenKey = "hostviewmodel.hidden"
    /** The key used to determine the section order */
    static var orderKey = "hostviewmodel.order"

    @Published var order: [String] { didSet {
        UserDefaults.standard.set(order, forKey: Self.orderKey)
    }}

    @Published var hidden: [String] {
        didSet {
            print("did set \(self.hidden.count) v \(self.sections.count)")
            UserDefaults.standard.set(self.hidden, forKey: Self.hiddenKey)
            objectWillChange.send()
            self.generateVisibleSections()
        }
    }

    init() {
        self.order = UserDefaults.standard.object(forKey: HostViewModel.orderKey) as? [String] ?? []
        self.hidden = UserDefaults.standard.object(forKey: HostViewModel.hiddenKey) as? [String] ?? []
        self.sections = []
        self.generateVisibleSections()
    }

    static var shared: HostViewModel = .init()

    private func generateVisibleSections() {
        var all_sections = [
            LocalDnsModel(),
            WhoisXmlWhoisSectionModel(),
            WhoisXmlDnsSectionModel(),
            WhoisXmlReputationSectionModel(),
            WhoIsXmlContactsSectionModel(),
            GoogleWebRiskSectionModel(),
        ]
        all_sections.removeAll(where: { self.hidden.contains($0.service.name) })

        var ordered_sections = [HostSectionModel]()

        for sectionName in self.order {
            if let section = all_sections.first(where: { $0.service.name == sectionName }) {
                ordered_sections.append(section)
                all_sections.removeAll(where: { $0 == section })
            }
        }
        ordered_sections.append(contentsOf: all_sections)

        self.sections = ordered_sections.map {
            return HostViewSection(model: self, sectionModel: $0)
        }
    }

    @Published var isQuerying: Bool = false

    private var workItems = [DispatchWorkItem]()
    private let _queue = DispatchQueue(label: "HostViewModelQueue")

    func query(url: URL? = nil, completion block: (([Error]) -> Void)? = nil) async {
        self.cancel()
        self.isQuerying = true

        let group = DispatchGroup()
        let errors = ActorArray<Error>()

        for section in self.sections {
            group.enter()

            Task {
                DispatchWorkItem {
                    Task {
                        do {
                            _ = try await section.sectionModel.query(url: url)
                        } catch {
                            await errors.append([error])
                        }
                        group.leave()
                    }
                }.perform()
            }
        }

        group.notify(queue: .main) {
            Task {
                self.isQuerying = false
                block?(await errors.values)
            }
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
