//
//  ItemsByCategory.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import SwiftUI

struct ItemsByCategory: View {
    @State var title: String
    @State var listItems: [Item]?
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.25)
                .ignoresSafeArea()
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: 150), spacing: 5), count: 2)) {
                    ForEach(listItems ?? [], id: \.id) { item in
                        ItemView(viewModel: ItemViewModel(item: item))
                    }
                }
                .padding()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ItemsByCategory(title: "")
}
