//
//  CarrouselView.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import SwiftUI

struct CarrouselView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: CarrouselViewModel
    @StateObject var navigationViewModel = NavigationViewModel.shared
    
    var body: some View {
        switch viewModel.carrouselState {
        case .loading:
            section(isMock: true, listItems: Item.emptyItems)
        case .error:
            section(error: true)
        case .ready:
            section(isMock: false)
        }
    }
    
    @ViewBuilder func section(isMock: Bool = false, error: Bool = false, listItems: [Item]? = []) -> some View {
        VStack(alignment: .leading) {
            if isMock {
                    HStack {
                        Text(viewModel.category.name)
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                            .redacted(reason: .placeholder)
                            .shimmer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                            .redacted(reason: .placeholder)
                            .shimmer()
                    }
                    .font(.headline)
                    .bold()
                    .padding(.bottom)
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(listItems ?? [], id: \.id) { item in
                            ItemView(viewModel: ItemViewModel(item: item, isMock: isMock))
                                .disabled(isMock)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            } else if !isMock && !error {
                Button(action: {
                    navigationViewModel.navigateTo = AnyView(ItemsByCategory(title: viewModel.category.name, listItems: viewModel.listItems))
                    navigationViewModel.navigationIsActive = true
                }) {
                    HStack {
                        Text(viewModel.category.name)
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                    .font(.headline)
                    .bold()
                    .padding(.bottom)
                }
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(viewModel.listItems ?? [], id: \.id) { item in
                            ItemView(viewModel: ItemViewModel(item: item))
                        }
                    }
                }
                .scrollIndicators(.hidden)
            } else if error {
                HStack {
                    Text(viewModel.category.name)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray)
                }
                .font(.headline)
                .bold()
                .padding(.bottom)
                ErrorView(error: viewModel.error, errorString: viewModel.errorString) {
                    viewModel.getCarrouselData(category: viewModel.category)
                }
            }
        }
        .padding()
        .background(content: {
            RoundedRectangle(cornerRadius: 5)
                .fill(Material.regular)
        })
        .padding()
    }
}

#Preview {
    let viewModel = CarrouselViewModel(category: .init(id: "MLA1", name: "Skeleton"))
    
    return CarrouselView(viewModel: viewModel)
}
