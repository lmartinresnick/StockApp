//
//  DetailView.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import SwiftUI

struct DetailView: View {
    var body : some View {
        Text("THIS IS A FAKE VIEW")
    }
}
struct DetailSection: Identifiable, Codable {
    var id = UUID()
    var header: String?
    var items: [DetailItem]?
}

struct DetailItem: Identifiable, Codable {

    var id = UUID()
    var subtitle: String?
    var title: String?
    var url: URL?
    var headline: String?
    var timeAgo: String?
    var source: String?
    var image: URL?
    
}





