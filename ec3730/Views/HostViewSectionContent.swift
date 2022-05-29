//
//  HostViewSectionContent.swift
//  ec3730
//
//  Created by Ahmad Azam on 22/05/2022.
//  Copyright © 2022 Zachary Gorak. All rights reserved.
//

import SwiftUI

struct HostViewSectionContent: View {
    @ObservedObject var sectionModel: HostSectionModel
    var canQuery: Bool
    @Binding var showDemoData: Bool
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            if let storeModel = self.sectionModel.storeModel {
                if self.canQuery {
                    // Need se-0309
                    ForEach(self.sectionModel.content) { row in
                        row
                    }
                } else {
                    PurchaseCellView(model: storeModel, heading: sectionModel.dataFeed.name, subheading: sectionModel.service.description, showDemoData: $showDemoData)
                }
            } else {
                ForEach(self.sectionModel.content) { row in
                    row
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        .background(Color(UIColor.systemBackground))
    }
}
